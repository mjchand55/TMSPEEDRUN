#name "Speedrun map switcher"
#author "Glocom"
#category "Interactive"  
#include "Icons.as"
#include "Formatting.as"
#version "2.0.0"
#siteid 87

string version_title = "Speedrun map switcher v2.0.0";

bool menu_visibility = false; 
bool campaign_in_progress = false;
bool preload_cache = false;
bool notification_shown = false;
bool auto_next_map = true;
bool preload_cache_notification_visible = false;
bool preload_cache_finished = false;

enum CampaignMode {
	Idle = -1,
	Training = 3,
	Season = 0,
	Totd = 1,
	Custom = 2
}

CampaignMode current_mode = CampaignMode::Idle;

string summer_2020_campaign_id = "130";
string fall_2020_campaign_id = "4791";
string winter_2021_campaign_id = "6151";
string spring_2021_campaign_id = "8449";
string url = "";
string selected_mode = "";
string expected_map_uid = "";

string attach_id = "PlaySpeedrun";

int release_month = 7;
int release_year = 2020;

array<MapInfo@> campaign_maps;

class Campaign {
	array<string> campaign_ids;
}

class MapInfo {
	int campaign_id;
	string author;
	string name;
	int author_score;
	int gold_score;
	int silver_score;
	int bronze_score;
	string collection_name;
	string environment;
	string filename;
	bool is_playable;
	string map_id;
	string map_uid;
	string submitter;
	string timestamp;
	string file_url;
	string thumbnail_url;
	string author_displayname;
	string submitter_displayname;
	int exchange_id;
}

Campaign@ current_campaign;
Campaign@ previous_campaign;


void RenderMenu()
{
	if(UI::MenuItem(Icons::Trophy + " Speedrun map switcher", "", menu_visibility)) {
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
			CSmArenaClient@ playground = cast<CSmArenaClient>(app.CurrentPlayground);			
			if(playground == null && !preload_cache_notification_visible && app.ManiaPlanetScriptAPI.ActiveContext_ClassicDialogDisplayed && app.Network.MasterServer.Downloads.get_Length() == 0) {
				app.BasicDialogs.WaitMessage_Ok();		
			}
			if(preload_cache_notification_visible && !app.ManiaPlanetScriptAPI.ActiveContext_ClassicDialogDisplayed) {
				preload_cache_notification_visible = false;
				startnew(GoToNextMap);
			}
			if(preload_cache) {
				if (playground != null && playground.GameTerminals.Length > 0 && (playground.GameTerminals[0].UISequence_Current == ESGamePlaygroundUIConfig__EUISequence::Playing || playground.GameTerminals[0].UISequence_Current == ESGamePlaygroundUIConfig__EUISequence::Intro || playground.GameTerminals[0].UISequence_Current == ESGamePlaygroundUIConfig__EUISequence::RollingBackgroundIntro)) {
					notification_shown = false;
					startnew(GoToNextMap);
				} else {
					if(!notification_shown) {
						UI::ShowNotification("Downloading assets for map # " + (app.Network.NextChallengeIndex+1) + "/" + campaign_maps.get_Length(), 10000);
						notification_shown = true;
					}
				}
			}
			else if(!preload_cache_notification_visible && auto_next_map && playground != null && playground.GameTerminals.Length > 0 && playground.GameTerminals[0].UISequence_Current == ESGamePlaygroundUIConfig__EUISequence::Finish && playground.GameTerminals[0].UISequence_Current != ESGamePlaygroundUIConfig__EUISequence::UIInteraction) {
				if(playground != null && expected_map_uid == playground.Map.EdChallengeId) {
					notification_shown = false;
				}
				if(!preload_cache && playground.Map.EdChallengeId != campaign_maps[campaign_maps.get_Length()-1].map_uid && !notification_shown) {
					UI::ShowNotification("Track: " + StripFormatCodes(campaign_maps[app.Network.NextChallengeIndex].name) + " (" + (app.Network.NextChallengeIndex+1) + "/" + campaign_maps.get_Length() + ")", 10000);
					expected_map_uid = campaign_maps[app.Network.NextChallengeIndex].map_uid;
					notification_shown = true;
				}
				startnew(GoToNextMap);
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
	UI::SetNextWindowSize(700,240, UI::Cond::FirstUseEver);			

	if (UI::Begin(version_title, menu_visibility)) {		
		if (UI::Button("Go to next map")) {
			if(campaign_in_progress) {
				ClosePauseMenu();
				UI::ShowNotification("Track: " + StripFormatCodes(campaign_maps[app.Network.NextChallengeIndex].name) + " (" + (app.Network.NextChallengeIndex+1) + "/" + campaign_maps.get_Length() + ")", 10000);
				startnew(GoToNextMap);
			}
		}	
		UI::SameLine();
		if (UI::Button("Abort speedrun")) {
			ClosePauseMenu();
			campaign_in_progress = false;
			app.BackToMainMenu();
		}		
		UI::SameLine();
		preload_cache = UI::Checkbox("Preload Cache", preload_cache);
		
		UI::SameLine();
		auto_next_map = UI::Checkbox("Auto load next map", auto_next_map);
			
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
				selected_mode = "Training";			
				ClosePauseMenu();				
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
				selected_mode = "Spring 2021";						
				ClosePauseMenu();			
				startnew(StartCampaign);
			}
			UI::SameLine();					
			if (UI::Button("Winter 2021")) {
				print("Starting Winter 2021 speedrun");
				current_mode = CampaignMode::Season;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(winter_2021_campaign_id);		
				selected_mode = "Winter 2021";				
				ClosePauseMenu();			
				startnew(StartCampaign);

			}
			
			if (UI::Button("Fall 2020")) {
				print("Starting Fall 2020 speedrun");
				current_mode = CampaignMode::Season;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(fall_2020_campaign_id);
				selected_mode = "Fall 2020";					
				ClosePauseMenu();			
				startnew(StartCampaign);

			}
			UI::SameLine();					
			if (UI::Button("Summer 2020")) {
				print("Starting Summer 2020 speedrun");
				current_mode = CampaignMode::Season;
				previous_campaign.campaign_ids = current_campaign.campaign_ids;	
				current_campaign.campaign_ids = {};
				current_campaign.campaign_ids.InsertLast(summer_2020_campaign_id);	
				selected_mode = "Summer 2020";				
				ClosePauseMenu();			
				startnew(StartCampaign);

			}
			UI::EndChild();
			UI::EndTabItem();
		}

		if (UI::BeginTabItem(Icons::CalendarAlt + " Track of the Day")) {
			UI::BeginChild("Track of the Day");	
			DrawTotdButtons();
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
				selected_mode = "All seasons 2020";				
				ClosePauseMenu();				
				startnew(StartCampaign);
			}
			UI::EndChild();
			UI::EndTabItem();
		}
		if (UI::BeginTabItem(Icons::Table + " All TOTDs")) {
			UI::BeginChild("All TOTDs");	
			DrawAllTotdsButtons();
			UI::EndChild();
			UI::EndTabItem();
		}
		if (UI::BeginTabItem(Icons::Boxes + " Custom")) {
			UI::BeginChild("Custom");
			url = UI::InputText("Enter trackmania.io url", url, UI::InputTextFlags(UI::InputTextFlags::AutoSelectAll | UI::InputTextFlags::NoUndoRedo));
			if (UI::Button("Start custom campaign")) {
				if(url != "" && Regex::IsMatch(url, "(?:https://trackmania.io/#/campaigns/)+\\d+/+\\d+", Regex::Flags(Regex::Flags::CaseInsensitive | Regex::Flags::ECMAScript))) {
					print("Starting custom speedrun");
					current_mode = CampaignMode::Custom;
					previous_campaign.campaign_ids = current_campaign.campaign_ids;	
					current_campaign.campaign_ids = {};
					string custom_campaign_id = Regex::Replace(url, "(?:https://trackmania.io/#/campaigns/)", "", Regex::Flags(Regex::Flags::CaseInsensitive | Regex::Flags::ECMAScript));
					current_campaign.campaign_ids.InsertLast(custom_campaign_id);				
					ClosePauseMenu();							
					startnew(StartCampaign);
				} else {
					print("Unknown campaign");
				}
			}
			UI::EndChild();
			UI::EndTabItem();
		}
		UI::EndTabBar();
	}
	UI::End();
}

CGameUILayer@ RunManiascript(string attach_id, string manialink) {
	CTrackMania@ app = cast<CTrackMania>(GetApp());
    CGameManiaAppTitle@ mania_app = app.MenuManager.MenuCustom_CurrentManiaApp;
    if (mania_app is null) return null;
    CGameUILayer@ layer = GetUILayer(attach_id);
    if (layer !is null) mania_app.UILayerDestroy(layer);
    @layer = mania_app.UILayerCreate();
    layer.ManialinkPage = manialink;
    layer.AttachId = attach_id;
    layer.IsVisible = false;
    return layer;
}

CGameUILayer@ GetUILayer(string attach_id) {
    CTrackMania@ app = cast<CTrackMania>(GetApp());
    CGameManiaAppTitle@ mania_app = app.MenuManager.MenuCustom_CurrentManiaApp;
    if (mania_app is null) return null;
    for (uint i = 0; i < mania_app.UILayers.Length; ++i) {
        if (mania_app.UILayers[i].AttachId == attach_id) return mania_app.UILayers[i];
    }
    return null;
}

string CreateManialink() { return """
<script><!--
    #RequireContext CManiaAppTitleLayer
    #Include "TextLib" as TL
	

main() {
    declare Text[] MapUrls;
""" + CreateMapListString() + 
		
"""
    SendCustomEvent("Event_UpdateLoadingScreen", [""" + "\"" + selected_mode + "\"" + """]);

	declare Text Settings = "<root><setting name=\"S_CampaignId\" value=\" """ +  campaign_maps[0].campaign_id + """ \" type=\"integer\"/><setting name=\"S_CampaignType\" value=\" """ + current_mode + """ \" type=\"integer\"/><setting name=\"S_CampaignIsLive\" value=\"False\" type=\"boolean\"/><setting name=\"S_ClubCampaignTrophiesAreEnabled\" value=\"False\" type=\"boolean\"/><setting name=\"S_DecoImageUrl_Checkpoint\" value=\"\" type=\"text\"/><setting name=\"S_DecoImageUrl_DecalSponsor4x1\" value=\"\" type=\"text\"/><setting name=\"S_DecoImageUrl_Screen16x9\" value=\"\" type=\"text\"/><setting name=\"S_DecoImageUrl_Screen8x1\" value=\"\" type=\"text\"/><setting name=\"S_DecoImageUrl_Screen16x1\" value=\"\" type=\"text\"/></root>";

    TitleControl.PlayMapList(MapUrls, "TrackMania/TM_Campaign_Local.Script.txt", Settings);
}
--></script>
""";
}

string CreateMapListString() {
	string maplist = "";
	for (uint i = 0; i < campaign_maps.get_Length(); i++) {
		maplist += "MapUrls.add(\"" + campaign_maps[i].file_url + "\");\n";
	}
	return maplist;
}

void ClosePauseMenu() {		
	CTrackMania@ app = cast<CTrackMania>(GetApp());		
	if(app.ManiaPlanetScriptAPI.ActiveContext_InGameMenuDisplayed) {
		CSmArenaClient@ playground = cast<CSmArenaClient>(app.CurrentPlayground);
		if(playground != null) {
			playground.Interface.ManialinkScriptHandler.CloseInGameMenu(EInGameMenuResult::Resume);
		}
	}
}

void DrawTotdButtons() {
	int current_month = Text::ParseInt(Time::FormatString("%m"));
	int current_year = Text::ParseInt(Time::FormatString("%Y"));

	auto diff = current_month - release_month + (12 * (current_year - release_year));
	int64 current_epoch = Time::get_Stamp() - (Text::ParseInt(Time::FormatString("%d"))*86400);
	
	current_month--; //subtract 1 month, because we can't speedrun the current TOTD month
	UI::Text("" + current_year);
	UI::NewLine();
	for(int i = diff; i > 0; i--) {		
		if(current_month % 6 != 0) 
			UI::SameLine();
		if (UI::Button(Time::FormatString("%B %Y", current_epoch))) {
			print("Starting " + Time::FormatString("%B %Y", current_epoch) + " speedrun");
			current_mode = CampaignMode::Totd;
			previous_campaign.campaign_ids = current_campaign.campaign_ids;	
			current_campaign.campaign_ids = {};
			current_campaign.campaign_ids.InsertLast("" + (diff - i + 1));	
			selected_mode = Time::FormatString("%B %Y", current_epoch);				
			ClosePauseMenu();			
			startnew(StartCampaign);
		}
		current_epoch -= GetDaysInMonthEpoch(current_month, current_year);
		if(current_month <= 1) {
			current_month = 12;
			current_year--;
			UI::Separator();
			UI::Text("" + current_year);
		} else {			
			current_month--;
		}
	}
}

int64 GetDaysInMonthEpoch(int month, int year) {
	int64 secondsInADay = 86400;
	if(month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
		return 31*secondsInADay;
	if(month == 4 || month == 6 || month == 9 || month == 11) 
		return 30*secondsInADay;
	if(month == 2) {
		if (year % 4 == 0) {
			return 29*secondsInADay;
		} else {
			return 28*secondsInADay;
		}
	}
	return 0;
}

void DrawAllTotdsButtons() {
	int current_month = Text::ParseInt(Time::FormatString("%m"));
	int current_year = Text::ParseInt(Time::FormatString("%Y"));
	int year_counter = current_year - 1; //subtract 1 year, because we can't speedrun the current TOTD year

	auto diff = current_month - release_month + (12 * (current_year - release_year));
	int64 current_epoch = Time::get_Stamp() - (Text::ParseInt(Time::FormatString("%m"))*2629743) - (Text::ParseInt(Time::FormatString("%d"))*86400);
	
	bool release_year = false;
	for(int i = 0; i < diff; i+=12) {	
		if(year_counter % 5 != 0) 
			UI::SameLine();
		if (UI::Button(Time::FormatString("%Y", current_epoch))) {
			print("Starting " + Time::FormatString("%Y", current_epoch) + " speedrun");
			current_mode = CampaignMode::Totd;
			previous_campaign.campaign_ids = current_campaign.campaign_ids;	
			current_campaign.campaign_ids = {};

			int january_of_selected_year = 12*(current_year - year_counter) + current_month - 1;
			if(year_counter == 2020) {
				january_of_selected_year = diff;
				release_year = true;
			}
			if(release_year) {
				for(int j = january_of_selected_year; j > january_of_selected_year - 6; j--) {
					current_campaign.campaign_ids.InsertLast("" + j);			
				}
			} else {
				for(int j = january_of_selected_year; j > january_of_selected_year - 12; j--) {
					current_campaign.campaign_ids.InsertLast("" + j);			
				}
			}
			selected_mode = Time::FormatString("All TOTDs %Y", current_epoch);	
			ClosePauseMenu();
			startnew(StartCampaign);
		}
		current_epoch -= 12*GetDaysInMonthEpoch(current_month, year_counter);
		year_counter--;
	}
}

void GoToNextMap() {
	if(campaign_in_progress) {
		sleep(1000);
		CTrackMania@ app = cast<CTrackMania>(GetApp());
		while(app.ManiaPlanetScriptAPI.ActiveContext_InGameMenuDisplayed) {
			yield();
		}
		CSmArenaClient@ playground = cast<CSmArenaClient>(app.CurrentPlayground);			
		if(playground == null && !preload_cache_notification_visible && app.ManiaPlanetScriptAPI.ActiveContext_ClassicDialogDisplayed && app.Network.MasterServer.Downloads.get_Length() == 0) {
			app.BasicDialogs.WaitMessage_Ok();		
		}
		if(preload_cache_finished && playground != null && playground.Map.EdChallengeId != campaign_maps[campaign_maps.get_Length()-1].map_uid) {
			preload_cache_finished = false;
		}
		if((playground != null && playground.Map.EdChallengeId != campaign_maps[campaign_maps.get_Length()-1].map_uid) || preload_cache_finished) {	
			app.Network.PlaygroundClientScriptAPI.RequestNextMap();
		}
		else {
			if(preload_cache && playground != null && playground.Map.EdChallengeId == campaign_maps[campaign_maps.get_Length()-1].map_uid) {
				print("Cache downloaded, restarting the campaign for the speedrun");
				app.ManiaPlanetScriptAPI.Dialog_Message("Preloading cache finished. Click OK to start your speedrun.");
				preload_cache = false;
				preload_cache_notification_visible = true;
				preload_cache_finished = true;
			} 
			else if(!preload_cache_notification_visible){
				print("End of campaign");
				campaign_in_progress = false;
				preload_cache = false;
				current_mode = CampaignMode::Idle;
				app.BackToMainMenu();
			}
		}
	}
}

void StartCampaign() {	
	if(current_campaign.campaign_ids.get_Length() > 0) {
		CTrackMania@ app = cast<CTrackMania>(GetApp());
		app.BackToMainMenu();
		while(!app.ManiaTitleControlScriptAPI.IsReady) {
			yield();
		}
		bool use_cache = true;
		preload_cache_finished = false;
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
			if(campaign_maps.get_Length() > 0) {
				campaign_maps = {};
			}
			for(uint i = 0; i < current_campaign.campaign_ids.get_Length(); i++) {
				FetchCampaign(current_campaign.campaign_ids[i]);
			}			
		}		
		if(!preload_cache) {
			UI::ShowNotification("Track: " + StripFormatCodes(campaign_maps[app.Network.NextChallengeIndex].name) + " (" + (app.Network.NextChallengeIndex+1) + "/" + campaign_maps.get_Length() + ")", 10000);
		}
		RunManiascript(attach_id, CreateManialink());
		campaign_in_progress = true;
	}
}

void FetchCampaign(string campaignId) {
	if(current_mode == CampaignMode::Totd) {
		string response = SendReq("https://trackmania.io/api/totd/" + campaignId, false);
		Json::Value maps = Json::Parse(response);

		for (uint i = 0; i < maps["days"].get_Length(); i++) {
			MapInfo@ newmap = MapInfo();
			newmap.campaign_id = maps["days"][i]["campaignid"];
			newmap.author = maps["days"][i]["map"]["author"];
			newmap.name = maps["days"][i]["map"]["name"];
			newmap.author_score = maps["days"][i]["map"]["authorScore"];
			newmap.gold_score = maps["days"][i]["map"]["goldScore"];
			newmap.silver_score = maps["days"][i]["map"]["silverScore"];
			newmap.bronze_score = maps["days"][i]["map"]["bronzeScore"];
			newmap.collection_name = maps["days"][i]["map"]["collectionName"];
			newmap.environment = maps["days"][i]["map"]["environment"];
			newmap.filename = maps["days"][i]["map"]["filename"];
			newmap.is_playable = maps["days"][i]["map"]["isPlayable"];
			newmap.map_id = maps["days"][i]["map"]["mapId"];
			newmap.map_uid = maps["days"][i]["map"]["mapUid"];
			newmap.submitter = maps["days"][i]["map"]["submitter"];
			newmap.timestamp = maps["days"][i]["map"]["timestamp"];
			newmap.file_url = maps["days"][i]["map"]["fileUrl"];
			newmap.thumbnail_url = maps["days"][i]["map"]["thumbnailUrl"];
			newmap.author_displayname = maps["days"][i]["map"]["authordisplayname"];
			newmap.submitter_displayname = maps["days"][i]["map"]["submitterdisplayname"];
			newmap.exchange_id = maps["days"][i]["map"]["exchangeid"];
			campaign_maps.InsertLast(newmap);
		}
	} else if(current_mode == CampaignMode::Season || current_mode == CampaignMode::Custom) {
		string response = "";
		if(current_mode == CampaignMode::Season) {		
			response = SendReq("https://trackmania.io/api/officialcampaign/" + campaignId, false);
		} else {
			response = SendReq("https://trackmania.io/api/campaign/" + campaignId, false);
		}
		Json::Value maps = Json::Parse(response);

		for (uint i = 0; i < maps["playlist"].get_Length(); i++) {
			MapInfo@ newmap = MapInfo();
			//newmap.campaign_id = Text::ParseInt(campaignId);
			newmap.campaign_id = 0;
			newmap.author = maps["playlist"][i]["author"];
			newmap.name = maps["playlist"][i]["name"];
			newmap.author_score = maps["playlist"][i]["authorScore"];
			newmap.gold_score = maps["playlist"][i]["goldScore"];
			newmap.silver_score = maps["playlist"][i]["silverScore"];
			newmap.bronze_score = maps["playlist"][i]["bronzeScore"];
			newmap.collection_name = maps["playlist"][i]["collectionName"];
			newmap.environment = maps["playlist"][i]["environment"];
			newmap.filename = maps["playlist"][i]["filename"];
			newmap.is_playable = maps["playlist"][i]["isPlayable"];
			newmap.map_id = maps["playlist"][i]["mapId"];
			newmap.map_uid = maps["playlist"][i]["mapUid"];
			newmap.submitter = maps["playlist"][i]["submitter"];
			newmap.timestamp = maps["playlist"][i]["timestamp"];
			newmap.file_url = maps["playlist"][i]["fileUrl"];
			newmap.thumbnail_url = maps["playlist"][i]["thumbnailUrl"];
			newmap.author_displayname = maps["playlist"][i]["authordisplayname"];
			newmap.submitter_displayname = maps["playlist"][i]["submitterdisplayname"];
			newmap.exchange_id = maps["playlist"][i]["exchangeid"];
			campaign_maps.InsertLast(newmap);
		}

		if(current_mode == CampaignMode::Custom) {			
			selected_mode = maps["name"];	
		}
	} else if(current_mode == CampaignMode::Training) {		
		for (uint i = 1; i <= 25; i++) {
			MapInfo@ newmap = MapInfo();	
			newmap.campaign_id = 0;	
			newmap.file_url = "Campaigns/Training/Training - " + Text::Format("%02d", i) + ".Map.Gbx";
			newmap.name = "Training - " + Text::Format("%02d", i);
			campaign_maps.InsertLast(newmap);
		}
		campaign_maps[campaign_maps.get_Length()-1].map_uid = "TkyKsOEG7gHqVqjjc3A1Qj5rPgi";
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

