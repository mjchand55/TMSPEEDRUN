#name "Speedrun map switcher"
#author "Glocom"
#category "Interactive"  
#include "Icons.as"
#version "1.1.0"

bool menu_visibility = false; 
bool campaign_in_progress = false;
bool is_totd_campaign = false;

string summer_2020_campaign_id = "130";
string fall_2020_campaign_id = "4791";
string winter_2021_campaign_id = "6151";
string spring_2021_campaign_id = "8449";
uint map_counter = 0;

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
	auto app = cast<CTrackMania>(GetApp());
	while (app is null) {
		yield();
	}
	while (true) {
		if(campaign_in_progress) {				
			CSmArenaClient@ playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);		
			if(playground != null && playground.GameTerminals.Length > 0 && playground.GameTerminals[0].UISequence_Current == ESGamePlaygroundUIConfig__EUISequence::EndRound) {
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
			
		UI::Separator();
		UI::BeginTabBar("Category tabs");
		if (UI::BeginTabItem(Icons::FirstAid + " Training")) {
			UI::BeginChild("Training");
			UI::Text("NOT YET IMPLEMENTED");
			if (UI::Button("Start training")) {
				print("Starting Training speedrun");
			}
			UI::EndChild();
			UI::EndTabItem();
		}

		if (UI::BeginTabItem(Icons::Globe + " Seasonal Campaign")) {
			UI::BeginChild("Seasonal Campaign");	
			if (UI::Button("Spring 2021")) {
				print("Starting Spring 2021 speedrun");
				is_totd_campaign = false;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(spring_2021_campaign_id);				
				startnew(StartCampaign);
			}
			UI::SameLine();					
			if (UI::Button("Winter 2021")) {
				print("Starting Winter 2021 speedrun");
				is_totd_campaign = false;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(winter_2021_campaign_id);				
				startnew(StartCampaign);

			}
			
			if (UI::Button("Fall 2020")) {
				print("Starting Fall 2020 speedrun");
				is_totd_campaign = false;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(fall_2020_campaign_id);			
				startnew(StartCampaign);

			}
			UI::SameLine();					
			if (UI::Button("Summer 2020")) {
				print("Starting Summer 2020 speedrun");
				is_totd_campaign = false;
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
				is_totd_campaign = true;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['march2021']));			
				startnew(StartCampaign);

			}
			UI::SameLine();					
			if (UI::Button("February 2021")) {
				print("Starting February 2021 speedrun");
				is_totd_campaign = true;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['february2021']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("January 2021")) {
				print("Starting January 2021 speedrun");
				is_totd_campaign = true;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['january2021']));			
				startnew(StartCampaign);

			}
			
			if (UI::Button("December 2020")) {
				print("Starting December 2020 speedrun");
				is_totd_campaign = true;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['december2020']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("November 2020")) {
				print("Starting November 2020 speedrun");
				is_totd_campaign = true;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['november2020']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("October 2020")) {
				print("Starting October 2020 speedrun");
				is_totd_campaign = true;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['october2020']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("September 2020")) {
				print("Starting September 2020 speedrun");
				is_totd_campaign = true;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['september2020']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("August 2020")) {
				print("Starting August 2020 speedrun");
				is_totd_campaign = true;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(string(months['august2020']));			
				startnew(StartCampaign);

			}
			UI::SameLine();
			if (UI::Button("July 2020")) {
				print("Starting July 2020 speedrun");
				is_totd_campaign = true;
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
				is_totd_campaign = false;
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
				is_totd_campaign = true;
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

void GoToNextMap() {
	if(campaign_in_progress) {
		CTrackMania@ app = cast<CTrackMania>(GetApp());
		print("Going to next map with url: " + campaign_urls[map_counter]);
		app.BackToMainMenu();
		while(!app.ManiaTitleControlScriptAPI.IsReady) {
			yield();
		}
		if(map_counter < campaign_urls.get_Length()) {
			app.ManiaTitleControlScriptAPI.PlayMap(campaign_urls[map_counter], "", "");
			map_counter++;
		}
		else {
			print("End of campaign");
			campaign_in_progress = false;
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
	if(is_totd_campaign) {
		string response = SendReq("https://trackmania.io/api/totd/" + campaignId, false);
		Json::Value maps = Json::Parse(response);

		for (uint i = 0; i < maps["days"].get_Length(); i++) {
			string url = maps["days"][i]["map"]["fileUrl"];
			campaign_urls.InsertLast(url);
		}
	} else {		
		string response = SendReq("https://trackmania.io/api/officialcampaign/" + campaignId, false);
		Json::Value maps = Json::Parse(response);

		for (uint i = 0; i < maps["playlist"].get_Length(); i++) {
			string url = maps["playlist"][i]["fileUrl"];
			campaign_urls.InsertLast(url);
		}
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

