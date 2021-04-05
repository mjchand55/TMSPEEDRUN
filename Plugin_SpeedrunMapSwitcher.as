#name "Speedrun map switcher"
#author "Glocom"
#category "Interactive"  
#include "Icons.as"
#version "1.2.0"

bool menu_visibility = false; 
bool campaign_in_progress = false;
bool preload_cache = false;
bool download_notification_shown = false;

enum CampaignMode {
	Idle,
	Training,
	Season,
	Totd
}

CampaignMode current_mode = CampaignMode::Idle;

string summer_2020_campaign_id = "130";
string fall_2020_campaign_id = "4791";
string winter_2021_campaign_id = "6151";
string spring_2021_campaign_id = "8449";
uint map_counter = 0;

int release_month = 7;
int release_year = 2020;
int current_month;
int current_year;

dictionary months = {
	{'march2021', "1"}, 
	{'february2021', "2"}, 
	{'january2021', "3"}, 
	{'december2020', "4"}, 
	{'november2020', "5"}, 
	{'october2020', "6"}, 
	{'september2020', "7"}, 
	{'august2020', "8"}, 
	{'july2020', "9"}
};

array<string> campaign_urls;

class Campaign {
	array<string> campaign_ids;
}

Campaign@ current_campaign;
Campaign@ previous_campaign;


void RenderMenu()
{
	if(UI::MenuItem("Speedrun map switcher", "", menu_visibility)) {
		menu_visibility = !menu_visibility;	
	}
}

void Main()
{	
	@current_campaign = Campaign();
	@previous_campaign = Campaign();
	GenerateMonthDict();
	auto app = cast<CTrackMania>(GetApp());
	while (app is null) {
		yield();
	}
	while (true) {
		if(campaign_in_progress) {				
			CSmArenaClient@ playground = cast<CSmArenaClient>(app.CurrentPlayground);
			if(preload_cache) {
				if (playground != null && playground.GameTerminals.Length > 0 && (playground.GameTerminals[0].UISequence_Current == ESGamePlaygroundUIConfig__EUISequence::Playing || playground.GameTerminals[0].UISequence_Current == ESGamePlaygroundUIConfig__EUISequence::Intro)) {
					GoToNextMap();
				} else {
					if(!download_notification_shown) {
						print("Waiting for download of assets for map #" + map_counter + " - URL: "+ campaign_urls[map_counter-1]);
						UI::ShowNotification("Downloading assets for map # " + map_counter + "/" + campaign_urls.get_Length(), 10000);
						download_notification_shown = true;
					}
				}
			}
			else if(playground != null && playground.GameTerminals.Length > 0 && playground.GameTerminals[0].UISequence_Current == ESGamePlaygroundUIConfig__EUISequence::EndRound) {
				GoToNextMap();
			}
		}
		yield();
	}
}

void RenderInterface() {
	if (!menu_visibility) {
		return;
	}
	CTrackMania@ app = cast<CTrackMania>(GetApp());
	UI::SetNextWindowSize(440,240, UI::Cond::FirstUseEver);			

	if (UI::Begin("Speedrun map switcher", menu_visibility)) {		
		if (UI::Button("Go to next map")) {
			startnew(GoToNextMap);
		}	
		UI::SameLine();
		if (UI::Button("Abort speedrun")) {
			campaign_in_progress = false;
			app.BackToMainMenu();
		}		
		UI::SameLine();
		preload_cache = UI::Checkbox("Preload Cache", preload_cache);
			
		UI::Separator();
		UI::BeginTabBar("Category tabs");
		if (UI::BeginTabItem(Icons::FirstAid + " Training")) {
			UI::BeginChild("Training");
			if (UI::Button("Start training")) {
				print("Starting Training speedrun");
				current_mode = CampaignMode::Training;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast("Training");				
				startnew(StartCampaign);
			}
			UI::EndChild();
			UI::EndTabItem();
		}

		if (UI::BeginTabItem(Icons::Globe + " Seasonal Campaign")) {
			UI::BeginChild("Seasonal Campaign");	
			if (UI::Button("Spring 2021")) {
				print("Starting Spring 2021 speedrun");
				current_mode = CampaignMode::Season;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(spring_2021_campaign_id);				
				startnew(StartCampaign);
			}
			UI::SameLine();					
			if (UI::Button("Winter 2021")) {
				print("Starting Winter 2021 speedrun");
				current_mode = CampaignMode::Season;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(winter_2021_campaign_id);				
				startnew(StartCampaign);

			}
			
			if (UI::Button("Fall 2020")) {
				print("Starting Fall 2020 speedrun");
				current_mode = CampaignMode::Season;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(fall_2020_campaign_id);			
				startnew(StartCampaign);

			}
			UI::SameLine();					
			if (UI::Button("Summer 2020")) {
				print("Starting Summer 2020 speedrun");
				current_mode = CampaignMode::Season;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(summer_2020_campaign_id);			
				startnew(StartCampaign);

			}
			UI::EndChild();
			UI::EndTabItem();
		}

		if (UI::BeginTabItem(Icons::CalendarAlt + " Track of the Day")) {
			UI::BeginChild("Track of the Day");	
			//TODO make dynamic		
			if (UI::Button("March 2021")) {
				print("Starting March 2021 speedrun");
				current_mode = CampaignMode::Totd;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['march2021']));			
				startnew(StartCampaign);

			}
			UI::SameLine();					
			if (UI::Button("February 2021")) {
				print("Starting February 2021 speedrun");
				current_mode = CampaignMode::Totd;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['february2021']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("January 2021")) {
				print("Starting January 2021 speedrun");
				current_mode = CampaignMode::Totd;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['january2021']));			
				startnew(StartCampaign);

			}
			
			if (UI::Button("December 2020")) {
				print("Starting December 2020 speedrun");
				current_mode = CampaignMode::Totd;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['december2020']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("November 2020")) {
				print("Starting November 2020 speedrun");
				current_mode = CampaignMode::Totd;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['november2020']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("October 2020")) {
				print("Starting October 2020 speedrun");
				current_mode = CampaignMode::Totd;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['october2020']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("September 2020")) {
				print("Starting September 2020 speedrun");
				current_mode = CampaignMode::Totd;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['september2020']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("August 2020")) {
				print("Starting August 2020 speedrun");
				current_mode = CampaignMode::Totd;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['august2020']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("July 2020")) {
				print("Starting July 2020 speedrun");
				current_mode = CampaignMode::Totd;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['july2020']));			
				startnew(StartCampaign);

			}
			UI::EndChild();
			UI::EndTabItem();
		}

		if (UI::BeginTabItem(Icons::Trophy + " All Seasons")) {
			UI::BeginChild("All Seasons");
			if (UI::Button("2020")) {
				print("Starting All Seasons 2020 speedrun");	
				current_mode = CampaignMode::Season;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;			
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(summer_2020_campaign_id);	
				current_campaign.campaign_ids.InsertLast(fall_2020_campaign_id);				
				startnew(StartCampaign);
			}
			UI::EndChild();
			UI::EndTabItem();
		}
		if (UI::BeginTabItem(Icons::Table + " All TOTDs")) {
			UI::BeginChild("All TOTDs");		
			if (UI::Button("2020")) {
				print("Starting All TOTDs 2020 speedrun");
				current_mode = CampaignMode::Totd;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['july2020']));	
				current_campaign.campaign_ids.InsertLast(string(months['august2020']));	
				current_campaign.campaign_ids.InsertLast(string(months['september2020']));	
				current_campaign.campaign_ids.InsertLast(string(months['october2020']));	
				current_campaign.campaign_ids.InsertLast(string(months['november2020']));	
				current_campaign.campaign_ids.InsertLast(string(months['december2020']));			
				startnew(StartCampaign);
			}
			UI::EndChild();
			UI::EndTabItem();
		}
		UI::EndTabBar();
	}
	UI::End();
}

void GenerateMonthDict() {
	current_month = Text::ParseInt(Time::FormatString("%m"));
	current_year = Text::ParseInt(Time::FormatString("%Y"));

	auto diff = current_month - release_month + (12 * (current_year - release_year));
	
	for(int j = diff, dict_counter = 0; j > 0; j--, dict_counter++) {
		if(dict_counter == 0) {
			months["july2020"] = "" + j;
		}
		if(dict_counter == 1) {
			months["august2020"] = "" + j;
		}
		if(dict_counter == 2) {
			months["september2020"] = "" + j;
		}
		if(dict_counter == 3) {
			months["october2020"] = "" + j;
		}
		if(dict_counter == 4) {
			months["november2020"] = "" + j;
		}
		if(dict_counter == 5) {
			months["december2020"] = "" + j;
		}
		if(dict_counter == 6) {
			months["january2021"] = "" + j;
		}
		if(dict_counter == 7) {
			months["february2021"] = "" + j;
		}
		if(dict_counter == 8) {
			months["march2021"] = "" + j;
		}
	}
}

void GoToNextMap() {
	if(campaign_in_progress) {
		CTrackMania@ app = cast<CTrackMania>(GetApp());
		app.BackToMainMenu();
		while(!app.ManiaTitleControlScriptAPI.IsReady) {
			yield();
		}
		if(map_counter < campaign_urls.get_Length()) {			
			print("Going to next map with url: " + campaign_urls[map_counter]);
			app.ManiaTitleControlScriptAPI.PlayMap(campaign_urls[map_counter], "", "");
			map_counter++;
			if(preload_cache) {
				download_notification_shown = false;
			} else {
				UI::ShowNotification("Track number: " + map_counter + "/" + campaign_urls.get_Length(), 10000);
			}
		}
		else {
			if(preload_cache) {
				print("Cache downloaded, restarting the campaign for the speedrun");
				UI::ShowNotification("Restarting the speedrun. Good luck on your run!", 10000);
				preload_cache = false;
				map_counter = 0;
				GoToNextMap();
			} else {
				print("End of campaign");
				campaign_in_progress = false;
				preload_cache = false;
				current_mode = CampaignMode::Idle;
			}
		}
	}
}

void StartCampaign() {	
	if(current_campaign.campaign_ids.get_Length() > 0) {	
		map_counter = 0;
		CTrackMania@ app = cast<CTrackMania>(GetApp());
		app.BackToMainMenu();
		while(!app.ManiaTitleControlScriptAPI.IsReady) {
			yield();
		}
		bool use_cache = true;
		if(current_campaign.campaign_ids.get_Length() == previous_campaign.campaign_ids.get_Length()) {
			for(uint j = 0; j < current_campaign.campaign_ids.get_Length(); j++) {
				if(current_campaign.campaign_ids[j] != previous_campaign.campaign_ids[j]) {
					use_cache = false;
					break;
				}
			}	
		}
		else {
			use_cache = false;
		}

		if(!use_cache) {	
			if(campaign_urls.get_Length() > 0) {
				campaign_urls = {};
			}
			for(uint i = 0; i < current_campaign.campaign_ids.get_Length(); i++) {
				FetchCampaign(current_campaign.campaign_ids[i]);
			}			
		}
		app.ManiaTitleControlScriptAPI.PlayMap(campaign_urls[map_counter], "", "");
		map_counter++;
		campaign_in_progress = true;
	}
}

void FetchCampaign(string campaignId) {
	if(current_mode == CampaignMode::Totd) {
		string response = SendReq("https://trackmania.io/api/totd/" + campaignId, false);
		Json::Value maps = Json::Parse(response);

		for (uint i = 0; i < maps["days"].get_Length(); i++) {
			string url = maps["days"][i]["map"]["fileUrl"];
			campaign_urls.InsertLast(url);
		}
	} else if(current_mode == CampaignMode::Season) {		
		string response = SendReq("https://trackmania.io/api/officialcampaign/" + campaignId, false);
		Json::Value maps = Json::Parse(response);

		for (uint i = 0; i < maps["playlist"].get_Length(); i++) {
			string url = maps["playlist"][i]["fileUrl"];
			campaign_urls.InsertLast(url);
		}
	} else if(current_mode == CampaignMode::Training) {		
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 01.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 02.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 03.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 04.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 05.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 06.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 07.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 08.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 09.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 10.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 11.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 12.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 13.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 14.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 15.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 16.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 17.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 18.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 19.Map.Gbx");	
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 20.Map.Gbx");
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 21.Map.Gbx");
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 22.Map.Gbx");
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 23.Map.Gbx");
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 24.Map.Gbx");
		campaign_urls.InsertLast("Campaigns\\Training\\Training - 25.Map.Gbx");
	}
}

string SendReq(string route, bool isPost) {
	Net::HttpRequest req;
	if (isPost) {
		req.Method = Net::HttpMethod::Post;
	} else {
		req.Method = Net::HttpMethod::Get;
	}
	req.Headers["Accept"] = "application/json";
	req.Headers["User-Agent"] = "Glocom Speedrun map switcher";
	req.Headers["Content-Type"] = "application/json";
	req.Url = route;
	req.Start();
	while (!req.Finished()) {
		yield();
	}
  	return req.String();
}

