//create a method that says hello world
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.IO;
using System.Data.SqlClient;
using System.Data;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;
using System.Net.Http;

public string HelloWorld()
{
    return "Hello World";
}

//create another method that says hello world with a name
public string HelloWorld(string name)
{
    return "Hello World " + name;
}
//create another method that says hello world with a name and a number
public string HelloWorld(string name, int number)
{
    return "Hello World " + name + " " + number;
}
//create another method that says hello world with a name and a number and a boolean
public string HelloWorld(string name, int number, bool isTrue)
{
    return "Hello World " + name + " " + number + " " + isTrue;
}
//create another method that says hello world with a name and a number and a boolean and a date
public string HelloWorld(string name, int number, bool isTrue, DateTime date)
{
    return "Hello World " + name + " " + number + " " + isTrue + " " + date;
}
