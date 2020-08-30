class Rx_ServerSwitch extends Rx_Mutator
config(ServerSwitch);

var bool bSwitch;

var config int RangeToSwitchBeginning, RangeToSwitchEnd, MinPlayersToSwitch;

var config string DestinationURL, MatchBeginMessage, PreSwitchMessage;

var int Temp, Hour, Min, Sec;

function CheckShouldSwitch()
{
	GetTime();

	if (Hour >= RangeToSwitchBeginning && Hour <= RangeToSwitchEnd && Rx_TeamInfo(`WorldInfoObject.GRI.Teams[0]).ReplicatedSize + Rx_TeamInfo(`WorldInfoObject.GRI.Teams[1]).ReplicatedSize >= MinPlayersToSwitch)
		bSwitch = true;
	else
		bSwitch = false;

	`log(`showvar(RangeToSwitchBeginning) @ `showvar(Hour) @ `showvar(RangeToSwitchEnd) @ `showvar(bSwitch));
}

function OnMatchStart()
{
	CheckShouldSwitch();

	if (bSwitch && MatchBeginMessage != "")
		Announce(MatchBeginMessage);

	super.OnMatchStart();
}

function OnMatchEnd()
{
	CheckShouldSwitch();

	if (bSwitch)
	{
		SetTimer(7.5, true);
		SetTimer(`RxGameObject.EndGameDelay - 5, false, nameof(DoSwitch));
	}

	super.OnMatchEnd();
}

function Timer()
{
	Announce(PreSwitchMessage);
}

function Announce(coerce string Message)
{
	`WorldInfoObject.Game.BroadcastHandler.Broadcast(None, Message, 'Say');
}

function DoSwitch()
{
	local string TravelUrlConfigured;

	if (!bSwitch || DestinationURL == "") return;

	TravelUrlConfigured = `RxGameObject.TravelURL;
	`RxGameObject.TravelURL = DestinationURL;

	`RxGameObject.ProcessServerTravel(DestinationURL, true);

	`RxGameObject.TravelURL = TravelUrlConfigured;
}

function GetTime()
{
	GetSystemTime(Temp, Temp, Temp, Temp, Hour, Min, Sec, Temp);
}

DefaultProperties
{
	bSwitch=false
}