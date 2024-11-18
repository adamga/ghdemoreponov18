import os
import re
from datetime import datetime
import pandas as pd
import ujson
import numpy as np
from multiprocessing import Pool
import matplotlib.pyplot as plt
import copilot_utils_files
import pytz
import copilot_utils_helpers

class CopilotUtils:
  def __init__(self, cost_management_report_file, cost_management_report_file_sheet_name, tracker_file, tracker_file_sheet_name, copilot_billing_seats_path, copilot_usage_path, copilot_slugs_file):
    self.tracker_file = tracker_file
    self.tracker_file_sheet_name = tracker_file_sheet_name
    self.copilot_billing_seats_path = copilot_billing_seats_path
    self.copilot_usage_path = copilot_usage_path
    self.cost_management_report_file = cost_management_report_file
    self.cost_management_report_file_sheet_name = cost_management_report_file_sheet_name
    self.copilot_slugs_file = copilot_slugs_file
    self.orgs = ["RogersMobile", "RogersEngineering", "digitalmedia", "RogersCommunications"]
    self._org_repos_collaborators_cached_df = None
    self._org_repos_cached_df = None
    self._copilot_billing_seats_users_cached_df = None
    self._copilot_users_cached_df = None
    self._copilot_billing_seats_cached_df = None
    self.copilot_utils_files = copilot_utils_files.CopilotUtilsFiles(self.orgs, self.tracker_file, self.tracker_file_sheet_name, self.cost_management_report_file, self.cost_management_report_file_sheet_name, self.copilot_usage_path, self.copilot_billing_seats_path)
    self.copilot_helpers = copilot_utils_helpers.CopilotHelpers()

  def get_org_repos_df(self):
    return self.copilot_utils_files.get_org_repos_df()

  def get_org_repos_collaborators_df(self):
    return self.copilot_utils_files.get_org_repos_collaborators_df()

  def get_copilot_users_df(self):
    return self.copilot_utils_files.get_copilot_users_df()

  def get_cost_management_report_df(self):
    return self.copilot_utils_files.get_cost_management_report_df()

  def get_org_team_members_df(self):
    return self.copilot_utils_files.get_org_team_members_df()

  def get_copilot_usage_df(self):
    return self.copilot_utils_files.get_copilot_usage_df()

  def get_copilot_billing_seats_df(self, team_name=None):
    df = self.copilot_utils_files.get_copilot_billing_seats_df()
    if team_name is not None:
      return df[df['slug'] == team_name].reset_index(drop=True)
    return df

  def get_copilot_slugs_df(self):
    df = self.get_copilot_billing_seats_df()
    df = df['slug'].drop_duplicates().reset_index(drop=True).to_frame(name='slug')
    return df

  def get_cost_management_report_copilot_licensed_user_counts_df(self):
    cost_management_report_df = self.get_cost_management_report_df()
    copilot_licensed_user_counts_df = self.get_copilot_licensed_user_counts_df()
    df = self.copilot_helpers.join_dataframes(cost_management_report_df, copilot_licensed_user_counts_df, 'UsageDate', 'date', 'inner')
    return df[['Cost', 'date', 'total_licensed']]

  def get_copilot_licensed_scoa_partner_company_df(self):
    copilot_users_df = self.get_copilot_users_df()
    scoas_df = copilot_users_df.groupby('activation_date').apply(lambda x: [{'SCOA': sc, 'partner_company': pc, 'IT': it} for sc, pc, it in zip(x['SCOA'], x['partner_company'], x['IT'])]).reset_index(name='scoa_partner_company_it')
    scoas_df = self.copilot_helpers.insert_missing_dates(scoas_df, 'activation_date', 0)
    for index, row in scoas_df.iterrows():
      if index > 0:
        current_scoa_partner_companies = scoas_df.at[index, 'scoa_partner_company_it']
        previous_scoa_partner_companies = scoas_df.at[index - 1, 'scoa_partner_company_it']
        if not isinstance(current_scoa_partner_companies, list):
          current_scoa_partner_companies = []
        if not isinstance(previous_scoa_partner_companies, list):
          previous_scoa_partner_companies = []
        combined_scoa_partner_companies = current_scoa_partner_companies + previous_scoa_partner_companies
        scoas_df.at[index, 'scoa_partner_company_it'] = combined_scoa_partner_companies
    return scoas_df

  def get_copilot_licensed_scoa_partner_company_cost_management_report_df(self):
    cost_management_report_df = self.get_cost_management_report_copilot_licensed_user_counts_df()
    scoa_partner_company_df = self.get_copilot_licensed_scoa_partner_company_df()
    df =  self.copilot_helpers.join_dataframes(cost_management_report_df, scoa_partner_company_df, 'date', 'date', 'inner')
    df = self.copilot_helpers.explode_and_normalize(df, 'scoa_partner_company_it')
    return df

  def get_copilot_billing_seats_copilot_users_df(self, team_name=None):
    copilot_users_df = self.get_copilot_users_df()
    copilot_billing_seats_df = self.get_copilot_billing_seats_df(team_name)
    return self.copilot_helpers.join_dataframes(copilot_users_df, copilot_billing_seats_df, 'github_id', 'login', 'inner')

  def get_copilot_dormant_users_df(self, team_name=None):
    copilot_billing_seats_copilot_users_df = self.get_copilot_billing_seats_copilot_users_df(team_name)
    copilot_billing_seats_copilot_users_df['days_licensed'] = (copilot_billing_seats_copilot_users_df['generated_date'] - copilot_billing_seats_copilot_users_df['activation_date']).dt.days
    copilot_billing_seats_copilot_users_df.loc[copilot_billing_seats_copilot_users_df['days_since_last_activity'] > copilot_billing_seats_copilot_users_df['days_licensed'], 'days_since_last_activity'] = np.nan
    copilot_billing_seats_copilot_users_df = copilot_billing_seats_copilot_users_df[copilot_billing_seats_copilot_users_df['days_licensed'] > 30].reset_index(drop=True)
    copilot_billing_seats_copilot_users_df = copilot_billing_seats_copilot_users_df[copilot_billing_seats_copilot_users_df['days_since_last_activity'].isnull() | (copilot_billing_seats_copilot_users_df['days_since_last_activity'] > 30)].reset_index(drop=True)
    copilot_billing_seats_copilot_users_df = copilot_billing_seats_copilot_users_df.reset_index(drop=True)
    copilot_billing_seats_copilot_users_df = copilot_billing_seats_copilot_users_df[['slug', 'login', 'activation_date', 'generated_date', 'days_licensed', 'last_activity_at', 'days_since_last_activity']]
    return copilot_billing_seats_copilot_users_df

  def get_copilot_licensed_user_counts_df(self, team_name=None):
    copilot_billing_seats_copilot_users_df = self.get_copilot_billing_seats_copilot_users_df(team_name)
    df = copilot_billing_seats_copilot_users_df.groupby(['login', 'activation_date']).last().reset_index().groupby(['activation_date']).size().reset_index(name='licensed')
    current_date_utc = datetime.now(pytz.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    if not current_date_utc.date() in df['activation_date'].dt.date.values:
      new_row_df = pd.DataFrame({'activation_date': [current_date_utc], 'licensed': [0]})
      df = pd.concat([df, new_row_df], ignore_index=True)
    df = self.copilot_helpers.insert_missing_dates(df, 'activation_date', 0)
    df['total_licensed'] = df['licensed'].cumsum()
    return df

  def get_copilot_adoption_df(self, team_name=None):
    copilot_dormant_users_df = self.get_copilot_dormant_users_df(team_name)
    copilot_dormant_users_df = copilot_dormant_users_df.groupby('generated_date').agg(dormant_users=('generated_date', 'size')).reset_index()
    copilot_dormant_users_df['generated_date'] = pd.to_datetime(copilot_dormant_users_df['generated_date']).dt.date
    copilot_licensed_user_counts_df = self.get_copilot_licensed_user_counts_df(team_name)
    copilot_licensed_user_counts_df['date'] = pd.to_datetime(copilot_licensed_user_counts_df['date']).dt.date
    df = self.copilot_helpers.join_dataframes(copilot_dormant_users_df, copilot_licensed_user_counts_df, 'generated_date', 'date', 'inner')
    df.drop(columns=['date', 'licensed'], inplace=True)
    df.rename(columns={'generated_date': 'date'}, inplace=True)
    return df

  def get_copilot_total_usage_rates_df(self):
    df = self.get_copilot_usage_df()
    df.drop(columns=[col for col in df.columns if col.startswith('breakdown_')], inplace=True)
    df = df.drop_duplicates(subset=['day'], keep='last').reset_index(drop=True)
    df['activity_code_completion_rate'] = df['total_suggestions_count'] / df['total_active_users']
    df['activity_line_completion_rate'] = df['total_lines_suggested'] / df['total_active_users']
    df['activity_chat_rate'] = df['total_chat_turns'] / df['total_active_chat_users']
    df['total_acceptance_rate'] = df['total_acceptances_count'] / df['total_suggestions_count'] * 100
    df['total_lines_acceptance_rate'] = df['total_lines_accepted'] / df['total_lines_suggested'] * 100
    df['total_chat_acceptance_rate'] = df['total_chat_acceptances'] / df['total_chat_turns'] * 100
    return df

  def get_copilot_total_usage_activity_df(self, column_name):
    df = self.get_copilot_total_usage_rates_df()
    df = self.copilot_helpers.insert_missing_dates(df, 'day', np.nan)
    df['rolling_2_week_max'] = df[column_name].rolling(window=14,min_periods=1).max()
    return df[['date', column_name, 'rolling_2_week_max']]

  def get_copilot_total_usage_activity_code_completion_rate_df(self):
    return self.get_copilot_total_usage_activity_df('activity_code_completion_rate')

  def get_copilot_total_usage_activity_chat_rate_df(self):
    return self.get_copilot_total_usage_activity_df('activity_chat_rate')

  def get_copilot_total_usage_activity_line_completion_rate_df(self):
    return self.get_copilot_total_usage_activity_df('activity_line_completion_rate')

  def get_copilot_breakdown_usage_rates_df(self):
    df = self.get_copilot_usage_df()
    df.drop(columns=[col for col in df.columns if col.startswith('total_')], inplace=True)
    return df

  def get_copilot_by_breakdown_by_usage_rates_df(self, keep_column, drop_columns):
    df = self.get_copilot_breakdown_usage_rates_df()
    df.drop(columns=drop_columns, inplace=True)
    df = df.groupby(['day', keep_column]).sum().reset_index()
    df['breakdown_activity_code_completion_rate'] = df['breakdown_suggestions_count'] / df['breakdown_active_users']
    df['breakdown_acceptance_rate'] = df['breakdown_acceptances_count'] / df['breakdown_suggestions_count'] * 100
    df['breakdown_lines_acceptance_rate'] = df['breakdown_lines_accepted'] / df['breakdown_lines_suggested'] * 100
    return df

  def get_copilot_breakdown_editor_usage_rates_df(self):
    return self.get_copilot_by_breakdown_by_usage_rates_df('breakdown_editor', ['breakdown_language'])

  def get_copilot_breakdown_language_usage_rates_df(self):
    return self.get_copilot_by_breakdown_by_usage_rates_df('breakdown_language', ['breakdown_editor'])

  def get_org_repos_collaborators_copilot_billing_seats_df(self):
    copilot_billing_seats_df = self.get_copilot_billing_seats_df().drop_duplicates(subset=['login'], keep='last').reset_index(drop=True)
    org_repos_collaborators_df = self.get_org_repos_collaborators_df()
    df = self.copilot_helpers.join_dataframes(org_repos_collaborators_df, copilot_billing_seats_df, 'login', 'login', 'left')
    df = df[df['slug'].notnull()].reset_index(drop=True)
    return df[['slug', 'login', 'org', 'repo_name', 'role_name']]

  def plot_copilot_all_df(self):
    self.plot_copilot_totals_df()
    self.plot_copilot_acceptance_rates_df()
    self.plot_usage_activity_line_completion_df()
    self.plot_copilot_adoption_by_day_df()
    self.plot_usage_activity_code_completion_df()
    self.plot_usage_activity_chat_df()

  def plot_copilot_totals_df(self):
    df = self.get_copilot_usage_total_df()
    self.plot_df(df, ['day'], ['total_suggestions_count', 'total_lines_suggested', 'total_chat_turns'], 'Totals', 'totals_plot.png', None, None, 'Day', 'Total', {'total_suggestions_count': 'Suggestions', 'total_lines_suggested': 'Lines Suggested', 'total_chat_turns': 'Chat Turns'})

  def plot_copilot_acceptance_rates_df(self):
    df = self.get_copilot_usage_total_df()
    self.plot_df(df, ['day'], ['total_acceptance_rate', 'total_lines_acceptance_rate', 'total_chat_acceptance_rate'], 'Acceptance Rate', 'acceptance_rate_plot.png', 25.0, None, 'Day', 'Acceptance Rate', {'total_acceptance_rate': 'Suggestion Acceptance Rate', 'total_lines_acceptance_rate': 'Lines of Code Acceptance Rate', 'total_chat_acceptance_rate': 'Chat Acceptance Rate'})

  def plot_usage_activity_line_completion_df(self):
    df = self.get_usage_activity_line_completion_df()
    self.plot_df(df, ['date'], ['activity_line_completion_rate', 'rolling_2_week_max'], 'Line Completions per Active User', 'activity_line_completion_plot.png', 100.0, None, 'Day', 'Line Completion Rate', {'activity_line_completion_rate': 'Line Completions per Active User', 'rolling_2_week_max': 'Rolling 2-Week Max'})

  def plot_copilot_adoption_by_day_df(self):
    df = self.get_copilot_adoption_by_day_df()
    self.plot_df(df, ['generated_date'], ['adoption_rate'],'Adoption Rate', 'adoption_rate_plot.png', 60.0, None, 'Date', 'Adoption Rate', {'adoption_rate': 'Adoption Rate'})

  def plot_usage_activity_code_completion_df(self):
    df = self.get_usage_activity_code_completion_df()
    self.plot_df(df, ['date'], ['activity_code_completion_rate', 'rolling_2_week_max'], 'Code Completions per Active User', 'activity_code_completion_plot.png', 50.0, None, 'Day', 'Code Completion Rate', {'activity_code_completion_rate': 'Code Completions per Active User', 'rolling_2_week_max': 'Rolling 2-Week Max'})

  def plot_usage_activity_chat_df(self):
    df = self.get_usage_activity_chat_df()
    self.plot_df(df, ['date'], ['activity_chat_rate', 'rolling_2_week_max'], 'Chat Turns per Active Chat User', 'activity_chat_plot.png', 20.0, None, 'Day', 'Chat Turn Rate', {'activity_chat_rate': 'Chat Turns per Active Chat User', 'rolling_2_week_max': 'Rolling 2-Week Max'})

  def plot_df(self, df, x_columns, y_columns, title, filename, target=None, target_series=None, x_label=None, y_label=None, y_legend_labels=None, plot_size=(13, 9)):
    plt.clf()  # Clear the current figure to ensure no data from previous plots is included

    # Plot target_series if provided
    if target_series is not None:
      plt.plot(df[x_columns[0]], target_series, color='r', linestyle='--', label='Target Series')
    elif target is not None:
      plt.axhline(y=target, color='r', linestyle='--', label='Target')

    if y_legend_labels is None:
      y_legend_labels = {y: y for y in y_columns}

    for x_column in x_columns:
      for y_column in y_columns:
        plt.plot(df[x_column], df[y_column], label=y_legend_labels.get(y_column, y_column))

    if x_label is None:
      x_label = x_columns[0]
    plt.xlabel(x_label)

    if y_label is None:
      y_label = ' '.join(y_columns)
    plt.ylabel(y_label)

    plt.title(title)

    plt.xticks(rotation=45)

    x_ticks = df[x_columns[0]].unique()
    plt.xticks(ticks=x_ticks[::len(x_ticks)//10 or 1], rotation=45)

    plt.gcf().set_size_inches(*plot_size)

    plt.legend()
    # Create plots folder if it doesn't exist
    if not os.path.exists('plots'):
      os.makedirs('plots')

    plt.savefig('plots/'+filename)

  def is_cost_management_report_df_partial(df):
    min_date = df['UsageDate'].min()
    max_date = df['UsageDate'].max()
    if min_date.day == 1 and max_date.day == pd.to_datetime(max_date).days_in_month:
      False
    return True

  def get_month_year_for_cost_management_report_df(self, df):
    min_date = df['UsageDate'].min()
    return min_date.strftime('%B_%Y')

  def get_copilot_repos_by_team_name_by_permissions_df(self, team_name, permissions):
    team_members_df = self.get_copilot_team_members_by_team_name_df(team_name)
    df = self.get_org_repos_collaborators_df()
    df = df[df['login'].isin(team_members_df['login'])].reset_index(drop=True)
    mask = pd.Series([False] * len(df))
    for permission in permissions:
      if permission in df.columns:
        mask = mask | df[permission]
    filtered_df = df[mask].reset_index(drop=True)
    filtered_df = filtered_df.groupby(['org', 'repo_name']).agg({permission: 'any' for permission in permissions}).reset_index()
    filtered_df = filtered_df.sort_values(by=['org', 'repo_name']).reset_index(drop=True)
    filtered_df.drop(columns=permissions, inplace=True)
    filtered_df['org_repo_name'] = filtered_df['org'] + "/" + filtered_df['repo_name']
    filtered_df.drop(columns=['org', 'repo_name'], inplace=True)
    org_repos_df = self.get_org_repos_df()
    filtered_df = self.copilot_helpers.join_dataframes(filtered_df, org_repos_df, 'org_repo_name', 'full_name', 'inner').reset_index(drop=True)
    filtered_df.drop(columns=['org_repo_name'], inplace=True)
    return filtered_df

  def generate_copilot_portfolios(self):
    copilot_team_names_df = self.get_copilot_team_names_df()
    for index, row in copilot_team_names_df.iterrows():
      team_name = row['team_names']
      print("INFO: Processing team:", team_name)
      df = self.get_copilot_repos_by_team_name_by_permissions_df(team_name, ['admin', 'maintain'])
      print(df)
      self.write_df_to_csv(df, "portfolios", "portfolio-" + team_name + ".csv")

  def get_copilot_repos_by_team_name_df(self, team_name):
    team_members_df = self.get_copilot_team_members_by_team_name_df(team_name)
    df = self.get_org_repos_collaborators_df()
    return df[df['login'].isin(team_members_df['login'])].reset_index(drop=True)

  def get_org_repos_collaborators_by_permissions_df(self, permissions):
    df = self.get_org_repos_collaborators_df()
    mask = pd.Series([False] * len(df))
    for permission in permissions:
      if permission in df.columns:
        mask = mask | df[permission]
    filtered_df = df[mask].reset_index(drop=True)
    return filtered_df

  def get_copilot_team_members_df(self):
    org_team_members_df = self.get_org_team_members_df()
    copilot_team_names_df = self.get_copilot_team_names_df()
    df = org_team_members_df[org_team_members_df['team_name'].isin(copilot_team_names_df['team_names'])]
    return df

  def get_copilot_team_members_by_team_name_df(self, team_name):
    df = self.get_copilot_team_members_df()
    return df[df['team_name'] == team_name].reset_index(drop=True)