//------------------------------------------------------------------------------
//
//  PMDG 777X external connection sample 
// 
//------------------------------------------------------------------------------

#include "PMDG_777X_SDK.h"

#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#include <strsafe.h>

#include "SimConnect.h"

int     quit = 0;
HANDLE  hSimConnect = NULL;
bool    AircraftRunning = false;		
PMDG_777X_Control Control; 


enum DATA_REQUEST_ID {
	DATA_REQUEST,
	CONTROL_REQUEST,
	AIR_PATH_REQUEST
};

enum EVENT_ID {
	EVENT_SIM_START,	// used to track the loaded aircraft

	EVENT_LOGO_LIGHT_SWITCH,
	EVENT_FLIGHT_DIRECTOR_SWITCH,

	EVENT_KEYBOARD_A,
	EVENT_KEYBOARD_B,
	EVENT_KEYBOARD_C,
};

enum INPUT_ID {
	INPUT0			// used to handle key presses
};

enum GROUP_ID {
	GROUP_KEYBOARD		// used to handle key presses
};

/*
NOTE: the 777 doesn't send the SDK data by default.
You will need to add these lines to <FSX>\PMDG\PMDG 777X\777X_Options.ini: 

[SDK]
EnableDataBroadcast=1

to enable the data sending from the 777X.
*/


bool B777X_FuelPumpLAftLight = true;
bool B777X_TaxiLightSwitch = false;
bool B777X_LogoLightSwitch = false;

// This function is called when 777X data changes
void Process777XData (PMDG_777X_Data *pS)
{
	// test the data access:
	// get the state of an annunciator light and display it
	if (pS->FUEL_annunLOWPRESS_Aft[0] != B777X_FuelPumpLAftLight)
	{
		B777X_FuelPumpLAftLight = pS->FUEL_annunLOWPRESS_Aft[0];
		if (B777X_FuelPumpLAftLight)
			printf("LOW PRESS LIGHT: [ON]\n");
		else
			printf("LOW PRESS LIGHT: [OFF]\n");
	}

	// get the state of switches and save it for later use
	if (pS->LTS_Taxi_Sw_ON != B777X_TaxiLightSwitch)
	{
		B777X_TaxiLightSwitch = pS->LTS_Taxi_Sw_ON;
		if (B777X_TaxiLightSwitch)
			printf("TAXI LIGHTS: [ON]\n");
		else
			printf("TAXI LIGHTS: [OFF]\n");
	}

	if (pS->LTS_Logo_Sw_ON != B777X_LogoLightSwitch)
	{
		B777X_LogoLightSwitch = pS->LTS_Logo_Sw_ON;
		if (B777X_LogoLightSwitch)
			printf("LOGO LIGHTS: [ON]\n");
		else
			printf("LOGO LIGHTS: [OFF]\n");
	}
}

void toggleTaxiLightSwitch()
{
	// Test the first control method: use the control data area.
	if (AircraftRunning)
	{
 		bool New_TaxiLightSwitch = !B777X_TaxiLightSwitch;

		// Send a command only if there is no active command request and previous command has been processed by the 777X
		if (Control.Event == 0)
		{
			Control.Event = EVT_OH_LIGHTS_TAXI;		// = 69753
			if (New_TaxiLightSwitch)
				Control.Parameter = 1;
			else
				Control.Parameter = 0;
			SimConnect_SetClientData (hSimConnect, PMDG_777X_CONTROL_ID,	PMDG_777X_CONTROL_DEFINITION, 
				0, 0, sizeof(PMDG_777X_Control), &Control);
		}
	}
}

void toggleLogoLightsSwitch()
{
	// Test the second control method: send an event
	// use direct switch position
	bool New_LogoLightSwitch = !B777X_LogoLightSwitch;

	int parameter = New_LogoLightSwitch? 1 : 0;
	SimConnect_TransmitClientEvent(hSimConnect, 0, EVENT_LOGO_LIGHT_SWITCH, parameter, 
			SIMCONNECT_GROUP_PRIORITY_HIGHEST, SIMCONNECT_EVENT_FLAG_GROUPID_IS_PRIORITY);
}

void toggleFlightDirector()
{
	// Test the second control method: send an event
	// use mouse simulation to toggle the switch
 	SimConnect_TransmitClientEvent(hSimConnect, 0, EVENT_FLIGHT_DIRECTOR_SWITCH, MOUSE_FLAG_LEFTSINGLE,
 		SIMCONNECT_GROUP_PRIORITY_HIGHEST, SIMCONNECT_EVENT_FLAG_GROUPID_IS_PRIORITY);
	SimConnect_TransmitClientEvent(hSimConnect, 0, EVENT_FLIGHT_DIRECTOR_SWITCH, MOUSE_FLAG_LEFTRELEASE,
		SIMCONNECT_GROUP_PRIORITY_HIGHEST, SIMCONNECT_EVENT_FLAG_GROUPID_IS_PRIORITY);
	printf("Flight Director toggled.\n");
}

void CALLBACK MyDispatchProc(SIMCONNECT_RECV* pData, DWORD cbData, void *pContext)
{
	switch(pData->dwID)
	{
	case SIMCONNECT_RECV_ID_CLIENT_DATA: // Receive and process the 777X data block
		{
			SIMCONNECT_RECV_CLIENT_DATA *pObjData = (SIMCONNECT_RECV_CLIENT_DATA*)pData;

			switch(pObjData->dwRequestID)
			{
			case DATA_REQUEST:
				{
					PMDG_777X_Data *pS = (PMDG_777X_Data*)&pObjData->dwData;
					Process777XData(pS);
					break;
				}
			case CONTROL_REQUEST:
				{
					// keep the present state of Control area to know if the server had received and reset the command
					PMDG_777X_Control *pS = (PMDG_777X_Control*)&pObjData->dwData;
					Control = *pS;
					break;
				}
			}
			break;
		}

	case SIMCONNECT_RECV_ID_EVENT:	
		{
			SIMCONNECT_RECV_EVENT *evt = (SIMCONNECT_RECV_EVENT*)pData;
			switch (evt->uEventID)
			{
			case EVENT_SIM_START:	// Track aircraft changes
				{
					HRESULT hr = SimConnect_RequestSystemState(hSimConnect, AIR_PATH_REQUEST, "AircraftLoaded");
					break;
				}
			case EVENT_KEYBOARD_A:
				{
					toggleTaxiLightSwitch();
					break;
				}
			case EVENT_KEYBOARD_B:
				{
					toggleLogoLightsSwitch();
					break;
				}
			case EVENT_KEYBOARD_C:
				{
					toggleFlightDirector();
					break;
				}
			}
			break;
		}

	case SIMCONNECT_RECV_ID_SYSTEM_STATE: // Track aircraft changes
		{
			SIMCONNECT_RECV_SYSTEM_STATE *evt = (SIMCONNECT_RECV_SYSTEM_STATE*)pData;
			if (evt->dwRequestID == AIR_PATH_REQUEST)
			{
				if (strstr(evt->szString, "PMDG 777") != NULL)
					AircraftRunning = true;
				else
					AircraftRunning = false;
			}
			break;
		}

	case SIMCONNECT_RECV_ID_QUIT:
		{
			quit = 1;
			break;
		}

	default:
		printf("Received:%d\n",pData->dwID);
		break;
	}
}

void testCommunication()
{
    HRESULT hr;

    if (SUCCEEDED(SimConnect_Open(&hSimConnect, "PMDG 777X Test", NULL, 0, 0, 0)))
    {
        printf("Connected to Flight Simulator!\n");   
        
		// 1) Set up data connection

        // Associate an ID with the PMDG data area name
		hr = SimConnect_MapClientDataNameToID (hSimConnect, PMDG_777X_DATA_NAME, PMDG_777X_DATA_ID);

        // Define the data area structure - this is a required step
		hr = SimConnect_AddToClientDataDefinition (hSimConnect, PMDG_777X_DATA_DEFINITION, 0, sizeof(PMDG_777X_Data), 0, 0);

        // Sign up for notification of data change.  
		// SIMCONNECT_CLIENT_DATA_REQUEST_FLAG_CHANGED flag asks for the data to be sent only when some of the data is changed.
		hr = SimConnect_RequestClientData(hSimConnect, PMDG_777X_DATA_ID, DATA_REQUEST, PMDG_777X_DATA_DEFINITION, 
			SIMCONNECT_CLIENT_DATA_PERIOD_VISUAL_FRAME, SIMCONNECT_CLIENT_DATA_REQUEST_FLAG_CHANGED, 0, 0, 0);

		
		// 2) Set up control connection

		// First method: control data area
		Control.Event = 0;
		Control.Parameter = 0;

		// Associate an ID with the PMDG control area name
		hr = SimConnect_MapClientDataNameToID (hSimConnect, PMDG_777X_CONTROL_NAME, PMDG_777X_CONTROL_ID);

		// Define the control area structure - this is a required step
		hr = SimConnect_AddToClientDataDefinition (hSimConnect, PMDG_777X_CONTROL_DEFINITION, 0, sizeof(PMDG_777X_Control), 0, 0);
        
		// Sign up for notification of control change.  
		hr = SimConnect_RequestClientData(hSimConnect, PMDG_777X_CONTROL_ID, CONTROL_REQUEST, PMDG_777X_CONTROL_DEFINITION, 
			SIMCONNECT_CLIENT_DATA_PERIOD_VISUAL_FRAME, SIMCONNECT_CLIENT_DATA_REQUEST_FLAG_CHANGED, 0, 0, 0);
		
		// Second method: Create event IDs for controls that we are going to operate
		hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_LOGO_LIGHT_SWITCH, "#69748");		//EVT_OH_LIGHTS_LOGO
		hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_FLIGHT_DIRECTOR_SWITCH, "#69834");	//EVT_MCP_FD_SWITCH_L


		// 3) Request current aircraft .air file path
		hr = SimConnect_RequestSystemState(hSimConnect, AIR_PATH_REQUEST, "AircraftLoaded");
		// also request notifications on sim start and aircraft change
		hr = SimConnect_SubscribeToSystemEvent(hSimConnect, EVENT_SIM_START, "SimStart");


		// 4) Assign keyboard shortcuts
		hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_KEYBOARD_A);
		hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_KEYBOARD_B);
		hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_KEYBOARD_C);

		hr = SimConnect_AddClientEventToNotificationGroup(hSimConnect, GROUP_KEYBOARD, EVENT_KEYBOARD_A);
		hr = SimConnect_AddClientEventToNotificationGroup(hSimConnect, GROUP_KEYBOARD, EVENT_KEYBOARD_B);
		hr = SimConnect_AddClientEventToNotificationGroup(hSimConnect, GROUP_KEYBOARD, EVENT_KEYBOARD_C);

		hr = SimConnect_SetNotificationGroupPriority(hSimConnect, GROUP_KEYBOARD, SIMCONNECT_GROUP_PRIORITY_HIGHEST);

		hr = SimConnect_MapInputEventToClientEvent(hSimConnect, INPUT0, "shift+ctrl+a", EVENT_KEYBOARD_A);
		hr = SimConnect_MapInputEventToClientEvent(hSimConnect, INPUT0, "shift+ctrl+b", EVENT_KEYBOARD_B);
		hr = SimConnect_MapInputEventToClientEvent(hSimConnect, INPUT0, "shift+ctrl+c", EVENT_KEYBOARD_C);

		hr = SimConnect_SetInputGroupState(hSimConnect, INPUT0, SIMCONNECT_STATE_ON);


		// 5) Main loop
        while( quit == 0 )
        {
			// receive and process the 777X data
            SimConnect_CallDispatch(hSimConnect, MyDispatchProc, NULL);

            Sleep(1);
        } 

        hr = SimConnect_Close(hSimConnect);
    }
	else
		printf("Unable to connect!\n\n");
}

int __cdecl _tmain(int argc, _TCHAR* argv[])
{

    testCommunication();

	return 0;
}





