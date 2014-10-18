class Extension extends Julia.Extension
  implements Julia.InterestedInEventBroadcast,
             Julia.InterestedInInternalEventBroadcast,
             Julia.InterestedInMissionEnded,
             Julia.InterestedInPlayerNameChanged,
             Julia.InterestedInPlayerTeamSwitched,
             Julia.InterestedInPlayerAdminLogged,
             Julia.InterestedInPlayerDisconnected,
             Julia.InterestedInPlayerVoiceChanged,
             Julia.InterestedInCommandDispatched;

/**
 * Copyright (c) 2014 Sergei Khoroshilov <kh.sergei@gmail.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


import enum eVoiceType from SwatGame.SwatGUIConfig;

/**
 * String used to identify an auth entry in the cache table
 * @type string
 */
const CACHE_AUTH_KEY = "auth";

/**
 * Delimiter separating name from ip and TTL in an auth cache entry
 * @type string
 */
const CACHE_AUTH_DELIMITER = ";";


struct sFriendlyFireRule
{
    /**
     * A list of comma separated weapon friendly names (9mm SMG, Taser Stun Gun)
     * @type string
     */
    var string Weapons;

    /**
     * Admin action (kick, kickban, etc)
     * @type string
     */
    var string Action;

    /**
     * The number of friendly hits required for the action to be taken of
     * @type int
     */
    var int ActionLimit;

    /**
     * Indicate whether admins should be notified
     * @type bool
     */
    var bool Alert;

    /**
     * Indicate whether admins should also be ignored
     * @type bool
     */
    var bool IgnoreAdmins;

    /**
     * List of parsed comma separated Weapons
     * @type array<string>
     */
    var array<string> Parsed;
};

struct sInstantAction
{
    /**
     * Reference to the punished player
     * @type class'Julia.Player'
     */
    var Julia.Player Player;

    /**
     * Punishment type (AutoBalance, DisallowWords, etc)
     * @type string
     */
    var string Type;

    /**
     * The action that has been taken upon the player (forcelesslethal, forcemute, etc)
     * @type string
     */
    var string Action;

    /**
     * Current violation count
     * @type int
     */
    var int Count;

    /**
     * The original action limit that had been required for the action to be taken (0 - disabled)
     * @type int
     */
    var int Limit;
};

struct sDelayedAction
{
    /**
     * Punished player
     * @type class'Julia.Player'
     */
    var Julia.Player Player;

    /**
     * Punishment type
     * @type string
     */
    var string Type;

    /**
     * Admin action (kick, kickban, etc)
     * @type string
     */
    var string Action;

    /**
     * Time the action will be issued at (Level.TimeSeconds)
     * @type float
     */
    var float Time;

    /**
     * Time between warnings (seconds)
     * @type float
     */
    var float WarningInterval;

    /**
     * Time the player was last warned at (Level.TimeSeconds)
     * @type float
     */
    var float LatestWarningTime;

    /**
     * Message shown to the player every ActionWarningInterval seconds
     * @type string
     */
    var string WarningMessage;

    /**
     * Message shown to admins upon taking the action
     * @type string
     */
    var string ActionMessage;
};

struct sProtectedName
{
    /**
     * Wildcard friendly name, such as |MYT|*
     * @type string
     */
    var string Name;

    /**
     * Password required to use the protected name
     * @type string
     */
    var string Password;
};

/**
 * List of players, sorted in the order of their team switching
 * @type array<class'Julia.Player'>
 */
var protected array<Julia.Player> BalanceList;

/**
 * List of actions that should be issued upon reaching their respective action limits
 * @type array<struct'sInstantAction'>
 */
var protected array<sInstantAction> InstantActions;

/**
 * List of delayed admin actions that should be issued upon reaching their execution time
 * @type array<struct'sDelayedAction'>
 */
var protected array<sDelayedAction> DelayedActions;

/**
 * List of parsed protected name=password structs
 * @type array<struct'sProtectedName'>
 */
var protected array<sProtectedName> ProtectedNames;

/**
 * Indicate whether an auto balance is required in favor of the specified team
 * 0 = swat, 1 = suspects, -1 = not required
 * @type int
 */
var protected int AutoBalanceRequired;

/**
 * Indicate whether the `Teams will be balanced in AutoBalanceTime/2 seconds` message has been shown
 * @type bool
 */
var protected bool bAutoBalanceHalfTime;

/**
 * Time untill the next autobalancing
 * @type int
 */
var protected float AutoBalanceCounter;

/**
 * Indicate whether the autobalance feature is enabled
 * @type bool
 */
var config bool AutoBalance;

/**
 * Time required to perform auto balancing
 * @type int
 */
var config int AutoBalanceTime;

/**
 * Do not commence autobalance if admins are present on a server
 * @type bool
 */
var config bool AutoBalanceAdminPresent;

/**
 * An action (adminmod command) taken upon an unbalancer that has reached the action limit
 * @type string
 */
var config string AutoBalanceAction;

/**
 * Number of unbalances required for the action to be taken (0 - disabled)
 * @type int
 */
var config int AutoBalanceActionLimit;

/**
 * List of wildcard friendly disallowed names
 * @type array<string>
 */
var config array<string> DisallowNames;

/**
 * Admin action that should taken against a player using a name the DisallowNames list
 * @type string
 */
var config string DisallowNamesAction;

/**
 * Time required for the action above to be taken
 * @type int
 */
var config int DisallowNamesActionTime;

/**
 * Number of warnings to be display before taking the action
 * @type int
 */
var config int DisallowNamesActionWarnings;

/**
 * A list of "name password" pairs with the password required to use the assotiated name
 * @type array<string>
 */
var config array<string> ProtectNames;

/**
 * Indicate whether admins should be allowed to use protected names without password authentication
 * @type bool
 */
var config bool ProtectNamesIgnoreAdmins;

/**
 * Action to take against an unauthenticated player
 * @type string
 */
var config string ProtectNamesAction;

/**
 * Time required for the action to be taken against an unauthenticated player
 * @type int
 */
var config int ProtectNamesActionTime;

/**
 * Number of warnings to display
 * @type int
 */
var config int ProtectNamesActionWarnings;

/**
 * List of pattern friendly words that should not be allowed for players to use
 * @type array<string>
 */
var config array<string> DisallowWords;

/**
 * An AMMod admin action (such as forcemute or kick) that is taken upon a player using disallowed words
 * @type string
 */
var config string DisallowWordsAction;

/**
 * Number of times player's messages get filtered before the action is taken (0-disabled)
 * @type int
 */
var config int DisallowWordsActionLimit;

/**
 * Indicate whether admins should be immune to the DisallowWords filter
 * @type bool
 */
var config bool DisallowWordsIgnoreAdmins;

/**
 * Indicate whether admins should see original messages that have been filtered out
 * @type bool
 */
var config bool DisallowWordsAlertAdmins;

/**
 * Dont allow players to use VIP voice
 * @type bool
 */
var config bool DisallowVIPVoice;

/**
 * Indicate whether text decoration codes in player messages should be filtered out
 * @type bool
 */
var config bool FilterText;

/**
 * Indicate whether admins should be allowed to use text codes
 * @type bool
 */
var config bool FilterTextIgnoreAdmins;

/**
 * List of friendly fire rules
 * @type  array<struct'sFriendlyFireRule'>
 */
var config array<sFriendlyFireRule> FriendlyFire;

/**
 * @return  void
 */
public function PreBeginPlay()
{
    Super.PreBeginPlay();
    self.AutoBalanceRequired = -1;
}

/**
 * @return  void
 */
public function BeginPlay()
{
    Super.BeginPlay();

    self.ParseProtectedNames();

    self.Core.RegisterInterestedInEventBroadcast(self);
    self.Core.RegisterInterestedInInternalEventBroadcast(self);
    self.Core.RegisterInterestedInMissionEnded(self);
    self.Core.RegisterInterestedInPlayerNameChanged(self);
    self.Core.RegisterInterestedInPlayerTeamSwitched(self);
    self.Core.RegisterInterestedInPlayerAdminLogged(self);
    self.Core.RegisterInterestedInPlayerDisconnected(self);
    self.Core.RegisterInterestedInPlayerVoiceChanged(self);

    self.Core.GetDispatcher().Bind(
        "auth", self, self.Locale.Translate("AuthCommandUsage"), self.Locale.Translate("AuthCommandDescription"), true
    );
}

event Timer()
{
    self.CheckAutoBalance();
    self.CheckDelayedActions();
}

/**
 * Drop all issued admins actions upon a round end
 * 
 * @return  void
 */
public function OnMissionEnded()
{
    self.DropIssuedActions();
}

/**
 * Add a player to the balance list upon their change of team
 * This does also handle connected players
 * 
 * @see Julia.InterestedInPlayerTeamSwitched.OnPlayerTeamSwitched
 */
public function OnPlayerTeamSwitched(Julia.Player Player)
{
    self.AddToBalanceList(Player);
}

/**
 * Display a welcome message to a logged in admin
 * Also attempt to drop queued delayed admin actions if they have been set to ignore admins
 * 
 * @param   class'Julia.Player' Player
 * @return  void
 */
public function OnPlayerAdminLogged(Julia.Player Player)
{
    self.CheckProtectedName(Player);
    self.GreetAdmin(Player);

    // Let other admins see the log in
    class'Utils.LevelUtils'.static.TellAdmins(
        self.Level,
        self.Locale.Translate("AdminLoginMessage", Player.GetName(), Player.GetIpAddr()),
        Player.GetPC()
    );
}

/**
 * Get rid of references to a disconnected player upon their leaving
 * 
 * @see Julia.InterestedInPlayerDisconnected.OnPlayerDisconnected
 */
public function OnPlayerDisconnected(Julia.Player Player)
{
    self.DropAllActions(Player);
    self.RemoveFromBalanceList(Player);
}

/**
 * Run Say and TeamSay event messages through text filters
 * 
 * @see Julia.InterestedInEventBroadcast.OnEventBroadcast
 */
public function bool OnEventBroadcast(Julia.Player Player, Actor Sender, name Type, out string Msg, optional PlayerController Receiver, optional bool bHidden)
{
    if (!bHidden)
    {
        if (Player != None && (Type == 'Say' || Type == 'TeamSay'))
        {
            // Dont allow unauthenticated players to talk
            if (self.MatchDelayedAction(Player, "ProtectNames"))
            {
                class'Utils.LevelUtils'.static.TellPlayer(
                    self.Level, self.Locale.Translate("ProtectNamesNoChatMessage"), Player.GetPC()
                );
                return false;
            }
            // Filter the [b] [u] [c=xxxxxx] codes
            if (self.FilterText && (!Player.IsAdmin() || !self.FilterTextIgnoreAdmins))
            {
                Msg = class'Utils.StringUtils'.static.Filter(Msg);
            }
            // Dont allow empty messages
            if (Msg == "")
            {
                return false;
            }
            // Check whether the message contains a word from the DisallowWords list
            return self.CheckDisallowedWord(Msg, Player);
        }
    }
    return true;
}

/**
 * @see Julia.InterestedInInternalEventBroadcast.OnInternalEventBroadcast
 */
public function OnInternalEventBroadcast(name Type, optional string Msg, optional Julia.Player PlayerOne, optional Julia.Player PlayerTwo)
{
    if (Type == 'PlayerTeamHit')
    {
        self.PunishTeamKiller(PlayerOne, PlayerTwo, Msg);
    }
}

/**
 * Dont let players other than the VIP to use VIP voice
 * 
 * @see Julia.InterestedInPlayerVoiceChanged.OnPlayerVoiceChanged
 */
public function OnPlayerVoiceChanged(Julia.Player Player)
{
    if (self.DisallowVIPVoice && !Player.IsVIP())
    {
        if (Player.GetVoiceType() == VOICETYPE_VIP)
        {
            Player.SetVoiceType(VOICETYPE_Lead);
            log(self $ " forced " $ Player.GetName() $ " to use " $ GetEnum(eVoiceType, Player.GetVoiceType()));
        }
    }
}

/**
 * Check the new player name against filters
 * 
 * @see Julia.InterestedInPlayerNameChanged.OnPlayerNameChanged
 */
public function OnPlayerNameChanged(Julia.Player Player, string OldName)
{
    self.CheckProtectedName(Player);
    self.CheckDisallowedName(Player);
}

/**
 * Attempt to authenticate a player
 * 
 * @see Julia.InterestedInCommandDispatched.OnCommandDispatched
 */
public function OnCommandDispatched(Julia.Dispatcher Dispatcher, string Name, string Id, array<string> Args, Julia.Player Player)
{
    local sProtectedName Protected;

    if (Name == "auth")
    {
        if (Args.Length == 0)
        {
            Dispatcher.ThrowUsageError(Id);
            return;
        }

        if (self.MatchProtectedName(Player.GetName(), Protected))
        {
            if (!self.IsPlayerAuthenticated(Player, Protected))
            {
                if (Args[0] == Protected.Password)
                {
                    self.AuthenticatePlayer(Player, Protected);
                    Dispatcher.Respond(Id, self.Locale.Translate("ProtectNamesResponseAccepted"));
                }
                else
                {
                    Dispatcher.Respond(Id, self.Locale.Translate("ProtectNamesResponseRejected"));
                }
                return;
            }
        }
        Dispatcher.ThrowError(Id, self.Locale.Translate("ProtectNamesResponseInvalid"));
    }
}

/**
 * Show an admin welcome message
 * 
 * @param   class'Julia.Player' Player
 * @return  void
 */
protected function GreetAdmin(Julia.Player Player)
{
    local int i;
    local array<Julia.Player> Players;
    local array<string> AdminNames;
    local string Message;

    // Display "Welcome to Duty"
    class'Utils.LevelUtils'.static.TellPlayer(
        self.Level,
        self.Locale.Translate("AdminWelcomeMessage", Player.GetName()),
        Player.GetPC()
    );
    // Get names of logged in admins
    Players = self.Core.GetServer().GetPlayers();

    for (i = Players.Length-1; i >= 0; i--)
    {
        if (Players[i].GetPC() != None && Players[i].IsAdmin() && Players[i] != Player)
        {
            AdminNames[AdminNames.Length] = Players[i].GetName();
        }
    }
    if (AdminNames.Length == 0)
    {
        Message = self.Locale.Translate("AdminWelcomeListNone");
    }
    else if (AdminNames.Length == 1)
    {
        Message = self.Locale.Translate("AdminWelcomeListOne");
    }
    else
    {
        Message = self.Locale.Translate("AdminWelcomeListMany");
    }
    // Display them
    class'Utils.LevelUtils'.static.TellPlayer(
        self.Level,
        class'Utils.StringUtils'.static.Format(
            Message, class'Utils.ArrayUtils'.static.Join(AdminNames, ", "), AdminNames.Length
        ),
        Player.GetPC()
    );
}

/**
 * Check whether autobalance is required
 * 
 * @return  void
 */
protected function CheckAutoBalance()
{
    local Julia.Player Player;

    // Nothing to balance
    if (self.AutoBalanceRequired == -1)
    {
        return;
    } 
     // Wait for the game to start or the feature to be enabled ingame
    else if (self.Core.GetServer().GetGameState() != GAMESTATE_MidGame || !self.AutoBalance)
    {
        return;
    }
    // Time's up
    if (self.AutoBalanceCounter >= self.AutoBalanceTime)
    {
        // Get the last switched/joined player from the opposing team
        Player = self.GetLastJoinedPlayer(int(!bool(self.AutoBalanceRequired)));
        // Switch one player per tick to keep the BalanceList array up-to-date
        SwatGameInfo(Level.Game).ChangePlayerTeam(SwatGamePlayerController(Player.GetPC()));

        class'Utils.LevelUtils'.static.TellAll(
            self.Level, 
            self.Locale.Translate("AutoBalanceMessage", self.Locale.Translate("ServerString"), Player.GetName()),
            self.Locale.Translate("ActionColor")
        );
        // Punish the unbalancer
        self.IssueInstantAction(
            Player, 
            "AutoBalance", 
            self.AutoBalanceAction, 
            self.AutoBalanceActionLimit, 
            self.Locale.Translate("AutoBalancePunishMessage")
        );
        // Wait for further instructions
        self.AutoBalanceRequired = -1;

        return;
    }
    // Keep deducting time
    self.AutoBalanceCounter += class'Julia.Core'.const.DELTA;
    // Attempt to show the 'Teams will be balanced in %n seconds' message
    if (!self.bAutoBalanceHalfTime && self.AutoBalanceCounter >= self.AutoBalanceTime / 2)
    {
        class'Utils.LevelUtils'.static.TellAll(
            self.Level, 
            self.Locale.Translate("AutoBalanceWarning", self.AutoBalanceTime / 2),
            self.Locale.Translate("MessageColor")
        );
        self.bAutoBalanceHalfTime = true;
    }
}

/**
 * Add a player to the balance list
 * 
 * @param   class'Player' Player
 * @return  void
 */
protected function AddToBalanceList(Julia.Player Player)
{
    // Remove previous entries first
    self.RemoveFromBalanceList(Player, true);
    
    self.BalanceList[self.BalanceList.Length] = Player;
    // Check whether the teams have just been unbalanced
    self.CheckTeams();
}

/**
 * Remove a player from the balance list
 * 
 * @param   class'Player' Player
 * @param   bool bSkipCheck (optional)
 *          Indicate whether this is an intermediate action and no further balance check should be taken
 * @return  void
 */
protected function RemoveFromBalanceList(Julia.Player Player, optional bool bSkipCheck)
{
    local int i;

    for (i = self.BalanceList.Length-1; i >= 0; i--)
    {
        if (self.BalanceList[i] == Player)
        {
            self.BalanceList.Remove(i, 1);
        }
    }
    if (!bSkipCheck)
    {
        self.CheckTeams();
    }
}

/**
 * Check whether teams have been unbalanced and attempt to queue an autobalance action
 * 
 * @return  void
 */
protected function CheckTeams()
{
    local int SufferingTeam;

    if (self.Core.GetServer().IsCOOP())
    {
        return;
    }

    // Skip teams check if there are admins on the server
    if (
        (self.AutoBalanceAdminPresent || class'Utils.LevelUtils'.static.GetAdmins(Level).Length == 0) && 
        !self.AreTeamsBalanced(SufferingTeam)
    )
    {
        self.AutoBalanceRequired = SufferingTeam;
    }
    // Reset the counter
    else
    {
        self.AutoBalanceCounter = 0;
        self.AutoBalanceRequired = -1;
        self.bAutoBalanceHalfTime = false;
    }
}

/**
 * Tell whether teams are balanced
 * 
 * @param   int SufferingTeam (out)
 *          Team that is missing players
 * @return  bool
 */
protected function bool AreTeamsBalanced(out int SufferingTeam)
{
    local int i, Diff;
    local int Team[2];

    // The balance list is beleieved to be an up-to-date list of online players
    for (i = 0; i < self.BalanceList.Length; i++)
    {
        Team[self.BalanceList[i].GetTeam()]++;
    }

    Diff = Abs(Team[0]-Team[1]);
    // Check the difference
    if (Diff > 0)
    {
        SufferingTeam = int(Team[0] > Team[1]);
        // Check whether the difference is greater than 1 player
        // unless its VIP Escort and the swat team has only 1 or less players
        if (Diff > 1 || self.Core.GetServer().GetGameType() == MPM_VIPEscort && SufferingTeam == 0 && Team[0] <= 1)
        {
            return false;
        }
    }

    SufferingTeam = -1;

    return true;
}

/**
 * Return the player (other than VIP) that has joined team Team last
 * 
 * @param   int Team
 * @return  class'Julia.Player'
 */
protected function Julia.Player GetLastJoinedPlayer(int Team)
{
    local int i;

    for (i = self.BalanceList.Length-1; i >= 0; i--)
    {
        // Dont mess with the VIP
        if (!self.BalanceList[i].IsVIP() && self.BalanceList[i].GetLastTeam() == Team) // dont do GetTeam()
        {
            return self.BalanceList[i];
        }
    }
    return None;
}

/**
 * Tell whether Message contains is free from the words defined in DisallowWords
 * and the player is allowed 
 * 
 * @param   string Message
 * @param   class'Julia.Player' Player
 * @return  bool
 */
public function bool CheckDisallowedWord(string Message, Julia.Player Player)
{
    local int i, j;
    local array<string> Words;
    local string PunctChars, NormalizedMessage;

    if (self.DisallowWordsIgnoreAdmins && Player.IsAdmin())
    {
        // allow admins to use disallowed words
        return true;
    }

    PunctChars = "'!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~'";
    // Clear the message from text codes
    NormalizedMessage = class'Utils.StringUtils'.static.Filter(Message);
    // Remove the punctuation characters from the test message
    for (i = 0; i < Len(PunctChars); i++)
    {
        NormalizedMessage = class'Utils.StringUtils'.static.Replace(NormalizedMessage, Mid(PunctChars, i, 1), "");
    }

    Words = class'Utils.StringUtils'.static.SplitWords(NormalizedMessage);

    for (i = 0; i < self.DisallowWords.Length; i++)
    {
        for (j = 0; j < Words.Length; j++)
        {
            if (class'Utils.StringUtils'.static.Match(Words[j], self.DisallowWords[i]))
            {
                // Display a warning
                class'Utils.LevelUtils'.static.TellPlayer(
                    self.Level,
                    self.Locale.Translate("DisallowWordsWarningMessage"),
                    Player.GetPC()
                );
                // Let admins see the original message
                if (self.DisallowWordsAlertAdmins)
                {
                    class'Utils.LevelUtils'.static.TellAdmins(
                        self.Level,
                        self.Locale.Translate("DisallowWordsAdminMessage", Player.GetName(), Message),
                        Player.GetPC()  // dont display this message to the player
                    );
                }
                // Attempt to punish the player
                self.IssueInstantAction(
                    Player, 
                    "DisallowWords", 
                    self.DisallowWordsAction, 
                    self.DisallowWordsActionLimit, 
                    self.Locale.Translate("DisallowWordsPunishMessage")
                );
                return false;
            }
        }
    }
    return true;
}

/**
 * Attempt to issue a delayed action if Player is using a disallowed nickname
 * 
 * @param   class'Player' Player
 * @return  void
 */
protected function CheckDisallowedName(Julia.Player Player)
{
    local int i;
    local string Name;

    Name = class'Utils.StringUtils'.static.Filter(Player.GetName());

    for (i = 0; i < self.DisallowNames.Length; i++)
    {
        if (class'Utils.StringUtils'.static.Match(Name, self.DisallowNames[i]))
        {
            self.IssueDelayedAction(
                Player, 
                "DisallowNames", 
                self.DisallowNamesAction, 
                self.DisallowNamesActionTime, 
                self.DisallowNamesActionWarnings,
                self.Locale.Translate("DisallowNamesWarningMessage"),
                self.Locale.Translate("DisallowNamesPunishMessage")
            );
            return;
        }
    }
    // Attempt to drop a delayed action if the player had used a disallowed name
    self.DropDelayedAction(Player, "DisallowNames");
}

/**
 * Attempt to queue a delayed action if a player 
 * has not authenticated themself to use a protected nickname
 * 
 * @param   class'Julia.Player' Player
 * @return  void
 */
protected function CheckProtectedName(Julia.Player Player)
{
    local sProtectedName Protected;
    local string Name;
    
    Name = class'Utils.StringUtils'.static.Filter(Player.GetName());

    // Get the matching protected name
    if (self.MatchProtectedName(Name, Protected))
    {
        if (!self.IsPlayerAuthenticated(Player, Protected))
        {
            // Authenticate admins automatically
            if (Player.IsAdmin() && self.ProtectNamesIgnoreAdmins)
            {
                log(self $ ": succeffully authorized admin " $ Name $ " to use " $ Protected.Name);
                self.AuthenticatePlayer(Player, Protected);
            }
            else
            {
                self.IssueDelayedAction(
                    Player, 
                    "ProtectNames", 
                    self.ProtectNamesAction, 
                    self.ProtectNamesActionTime, 
                    self.ProtectNamesActionWarnings,
                    self.Locale.Translate("ProtectNamesWarningMessage"),
                    self.Locale.Translate("ProtectNamesPunishMessage")
                );
            }
            return;
        }
    }
    // Drop a queued action in case the player's previous name was a protected one
    self.DropDelayedAction(Player, "ProtectNames");
}

/**
 * Tell whether TestName matches one of protected names from the ProtectedNames list
 * 
 * @param   string TestName
 * @param   struct'sProtectedName' ProtectedName (out)
 * @return  bool
 */
protected function bool MatchProtectedName(string TestName, out sProtectedName ProtectedName)
{
    local int i;

    for (i = 0; i < self.ProtectedNames.Length; i++)
    {
        if (class'Utils.StringUtils'.static.Match(TestName, self.ProtectedNames[i].Name))
        {
            ProtectedName = self.ProtectedNames[i];
            return true;
        }
    }
    return false;
}

/**
 * Tell whether Player has authenticated themself to use ProtectedName
 * 
 * @param   class'Julia.Player' Player
 * @param   struct'sProtectedName'
 * @return  bool
 */
protected function bool IsPlayerAuthenticated(Julia.Player Player, sProtectedName ProtectedName)
{
    local int i;
    local array<string> Cached;

    log(self $ ": trying to authorize " $ Player.GetName() $ " to use " $ ProtectedName.Name);

    Cached = self.Core.GetCache().GetArray(class'Extension'.const.CACHE_AUTH_KEY);

    for (i = 0; i < Cached.Length; i++)
    {
        if (Cached[i] == (ProtectedName.Name $ class'Extension'.const.CACHE_AUTH_DELIMITER $ Player.GetIpAddr()))
        {
            log(self $ ": found a " $ Cached[i] $ " entry matching " $ Player.GetName());
            return true;
        }
    }
    log(self $ ": failed to authenticate " $ Player.GetName());
    return false;
}

/**
 * Authenticate a player to use a protected name
 * 
 * @param   class'Julia.Player' Player
 * @param   sProtectedName ProtectedName
 * @return  void
 */
protected function AuthenticatePlayer(Julia.Player Player, sProtectedName ProtectedName)
{
    self.Core.GetCache().Append(
        class'Extension'.const.CACHE_AUTH_KEY, 
        ProtectedName.Name $ class'Extension'.const.CACHE_AUTH_DELIMITER $ Player.GetIpAddr()
    );
    // Also drop queued actions
    self.DropDelayedAction(Player, "ProtectNames");
}

/**
 * Populate the ProtectedNames array with parsed name=password pairs
 * 
 * @return  void
 */
protected function ParseProtectedNames()
{
    local int i;
    local sProtectedName NewEntry;
    local array<string> Pair;

    for (i = 0; i < self.ProtectNames.Length; i++)
    {
        Pair = class'Utils.StringUtils'.static.SplitWords(self.ProtectNames[i]);

        if (Pair.Length != 2)
        {
            log(self $ " failed to parse a protected name: " $ self.ProtectNames[i]);
            continue;
        }

        NewEntry.Name = Pair[0];
        NewEntry.Password = Pair[1];

        self.ProtectedNames[self.ProtectedNames.Length] = NewEntry;
    }
}

/**
 * Attempt to punish Killer for friendly fire.
 * Additionally attempt to display the hit message to admins
 * 
 * @param   class'Julia.Player' Killer
 * @param   class'Julia.Player' Victim
 * @param   string Weapon
 * @return  void
 */
protected function PunishTeamKiller(Julia.Player Killer, Julia.Player Victim, string Weapon)
{
    local sFriendlyFireRule Rule;
    local string Message, Type;

    if (Weapon == "")
    {
        Weapon = "None";
        Message = self.Locale.Translate("FriendlyFireNoWeaponMessage");
    }
    else
    {
        Message = self.Locale.Translate("FriendlyFireMessage");
    }
    // Check if there is an appropriate ff rule for this weapon
    if (self.MatchFriendlyFireRule(Weapon, Rule))
    {
        // See if admins are ignored
        if (Killer.IsAdmin() && Rule.IgnoreAdmins)
        {
            return;
        }
        // Alert admins
        if (Rule.Alert)
        {
            class'Utils.LevelUtils'.static.TellAdmins(
                self.Level, 
                class'Utils.StringUtils'.static.Format(
                    Message, 
                    class'Julia.Utils'.static.GetTeamColoredName(Killer.GetName(), Killer.GetTeam(), Killer.IsVIP()),
                    class'Julia.Utils'.static.GetTeamColoredName(Victim.GetName(), Victim.GetTeam(), Victim.IsVIP()),
                    Weapon
                ),
                Killer.GetPC()
            );
        }
        // Attempt to punish the player
        if (Rule.Action != "" && Rule.ActionLimit > 0)
        {
            if (class'Extension'.static.GetPlayerTeamHits(Killer, Rule.Parsed) == Rule.ActionLimit)
            {
                // Each set of weapons yields its own punishment type
                Type = "FriendlyFire_" $ Left(ComputeMD5Checksum(Rule.Weapons), 6);
                self.IssueInstantAction(Killer, Type, Rule.Action, 1, self.Locale.Translate("FriendlyFirePunishMessage"));
            }
        }
    }
}

/**
 * Find the first FriendlyFire struct matching given weapon name
 *
 * @param   string WeaponName
 * @param   struct'sFriendlyFireRule' Rule (out)
 * @return  bool
 */
protected function bool MatchFriendlyFireRule(string WeaponName, out sFriendlyFireRule Rule)
{
    local int i, j;

    if (WeaponName != "")
    {
        for (i = 0; i < self.FriendlyFire.Length; i++)
        {
            // Parse comma separated list of weapons
            if (self.FriendlyFire[i].Parsed.Length == 0)
            {
                self.FriendlyFire[i].Parsed = class'Utils.StringUtils'.static.SplitWords(self.FriendlyFire[i].Weapons, ",");
            }

            for (j = 0; j < self.FriendlyFire[i].Parsed.Length; j++)
            {
                if (Caps(WeaponName) == Caps(self.FriendlyFire[i].Parsed[j]))
                {
                    Rule = self.FriendlyFire[i];
                    return true;
                }
            }
        }
    }
    return false; 
}

/**
 * Attempt to issue an instant action against a player
 * 
 * @param   class'Julia.Player' Player
 * @param   string Type
 * @param   string Action
 * @param   int ActionLimit
 * @param   string ActionMessage (optional)
 * @return  void
 */
protected function IssueInstantAction(Julia.Player Player, string Type, string Action, int ActionLimit, optional string ActionMessage)
{
    local int i;
    local int ActionIndex;
    local sInstantAction NewEntry;

    Action = class'Utils.StringUtils'.static.Strip(Action);

    if (Action == "" || Action ~= "none" || ActionLimit <= 0)
    {
        return;
    }

    ActionIndex = -1;
    // Attempt to find an existing open action
    for (i = 0; i < self.InstantActions.Length; i++)
    {
        if (self.InstantActions[i].Player == Player)
        {
            // The same action has already been taken
            if (self.InstantActions[i].Count >= self.InstantActions[i].Limit)
            {
                if (self.InstantActions[i].Action ~= Action)
                {
                    log(self $ ": " $ Player.GetName() $ " has already been punished with " $ Action);
                    return;
                }
            }
            else if (self.InstantActions[i].Type == Type)
            {
                ActionIndex = i;
            }
        }
    }
    if (ActionIndex == -1)
    {
        log(self $ ": setting up a new " $ Type $ " punishment");

        NewEntry.Player = Player;
        NewEntry.Action = Action;
        NewEntry.Type = Type;
        NewEntry.Limit = ActionLimit;

        ActionIndex = self.InstantActions.Length;
        self.InstantActions[ActionIndex] = NewEntry;
    }
    // Check if the player has reached the action limit
    if (++self.InstantActions[ActionIndex].Count == ActionLimit)
    {
        log(self $ ": issuing " $ Action $ " action against " $ Player.GetName());
        self.IssueAdminCommand(Action, Player, ActionMessage);
        return;
    }
}

/**
 * Attempt to issue delayed actions
 * 
 * @return  void
 */
protected function CheckDelayedActions()
{
    local int i;

    for (i = self.DelayedActions.Length-1; i >= 0; i--)
    {
        // Time's up
        if (self.DelayedActions[i].Time <= Level.TimeSeconds)
        {
            log(self $ ": time of " $ self.DelayedActions[i].Type $ " for " $ self.DelayedActions[i].Player.GetName() $ " has come up");
            // Issue a normal action
            self.IssueInstantAction(
                self.DelayedActions[i].Player, 
                self.DelayedActions[i].Type, 
                self.DelayedActions[i].Action, 
                1,  // instant
                self.DelayedActions[i].ActionMessage
            );
            self.DelayedActions.Remove(i, 1);
        }
        // Keep showing warnings
        else if (self.DelayedActions[i].LatestWarningTime < Level.TimeSeconds - self.DelayedActions[i].WarningInterval)
        {
            log(self $ ": displaying a warning to " $ self.DelayedActions[i].Player.GetName() $ " for " $ self.DelayedActions[i].Type);
            
            class'Utils.LevelUtils'.static.TellPlayer(
                self.Level, self.DelayedActions[i].WarningMessage, self.DelayedActions[i].Player.GetPC()
            );
            self.DelayedActions[i].LatestWarningTime = Level.TimeSeconds;
        }
    }
}

/**
 * Attempt to queue a delayed action of type Type against Player
 * 
 * @param   class'Julia.Player' Player
 * @param   string Type
 * @param   string Action
 * @param   int ActionTime
 * @param   int Warnings
 * @param   string WarningMessage
 * @param   string PunishMessahe
 * @return  void
 */
protected function IssueDelayedAction(Julia.Player Player, string Type, string Action, int ActionTime, int Warnings, string WarningMessage, string ActionMessage)
{
    local sDelayedAction NewEntry;

    Action = class'Utils.StringUtils'.static.Strip(Action);

    if (Action == "" || Action ~= "none")
    {
        log(self $ ": wont queue " $ Type $ " against " $ Player.GetName());
        return;
    }
    if (self.MatchDelayedAction(Player, Type))
    {
        log(self $ ": " $ Type $ " against " $ Player.GetName() $ " has already been queued");
        return;
    }

    NewEntry.Player = Player;
    NewEntry.Type = Type;
    NewEntry.Action = Action;
    NewEntry.Time = FMax(1.0, float(ActionTime)) + Level.TimeSeconds;
    NewEntry.WarningInterval = FMax(1.0, float(ActionTime)/float(Warnings));
    NewEntry.WarningMessage = WarningMessage;
    NewEntry.ActionMessage = ActionMessage;

    self.DelayedActions[self.DelayedActions.Length] = NewEntry;
    log(self $ ": successfuly queued " $ Type $ " against " $ Player.GetName());
}

/**
 * Tell if there is a delayed action matching given Player and Type
 * 
 * @param   class'Julia.Player' Player
 * @param   string Type
 * @return  bool
 */
protected function bool MatchDelayedAction(Julia.Player Player, string Type)
{
    local int i;

    for (i = 0; i < self.DelayedActions.Length; i++)
    {
        if (self.DelayedActions[i].Player == Player && self.DelayedActions[i].Type == Type)
        {
            return true;
        }
    }
    return false;
}

/**
 * Attempt to drop a delayed action matching given Type and Player
 * 
 * @param   class'Julia.Player' Player
 * @param   string Type
 * @return  void
 */
protected function DropDelayedAction(Julia.Player Player, string Type)
{
    local int i;

    for (i = self.DelayedActions.Length-1; i >= 0 ; i--)
    {
        if (self.DelayedActions[i].Player == Player && self.DelayedActions[i].Type == Type)
        {
            log(self $ ": dropping a " $ Type $ " action for " $ Player.GetLastName());
            self.DelayedActions.Remove(i, 1);
            break;
        }
    }
}

/**
 * Attempt to lift all taken punishment actions
 * 
 * @return  voud
 */
protected function DropIssuedActions()
{
    local int i;

    for (i = self.InstantActions.Length-1; i >= 0; i--)
    {
        // Only lift actions that have actually been issued
        if (self.InstantActions[i].Count < self.InstantActions[i].Limit)
        {
            continue;
        }

        log(self $ ": lifting a " $ self.InstantActions[i].Type $ " punishment of " $ self.InstantActions[i].Player.GetLastName());

        // Unmute the player (other admin actions dont normally persist through rounds)
        if (self.InstantActions[i].Action ~= "forcemute")
        {
            self.IssueAdminCommand("forcemute", self.InstantActions[i].Player);
        }

        self.InstantActions[i].Player = None;
        self.InstantActions.Remove(i, 1);
    }
}

/**
 * Drop all action entries 
 * 
 * @param   class'Julia.Player' Player (optional)
 * @return  void
 */
protected function DropAllActions(optional Julia.Player Player)
{
    local int i;

    for (i = self.InstantActions.Length-1; i >= 0; i--)
    {
        if (Player == None || self.InstantActions[i].Player == Player)
        {
            log(self $ ": dropping " $ self.InstantActions[i].Type);
            self.InstantActions[i].Player = None;
            self.InstantActions.Remove(i, 1);
        }
    }

    for (i = self.DelayedActions.Length-1; i >= 0; i--)
    {
        if (Player == None || self.DelayedActions[i].Player == Player)
        {
            log(self $ ": dropping " $ self.DelayedActions[i].Type);
            self.DelayedActions[i].Player = None;
            self.DelayedActions.Remove(i, 1);
        }
    }
}

/**
 * Issue an arbitrary AdminMod command. 
 * If Player argument is provided, append its AM player id to the command
 * 
 * @param   string AdminCommand
 *          Arbitrary admin command
 * @param   class'Player' Player (optional)
 *          Optional target
 * @param   string ActionMessage (optional)
 *          An optional message to display upon the action being taken
 * @return  void
 */
protected function IssueAdminCommand(string AdminCommand, optional Julia.Player Player, optional string ActionMessage)
{
    if (ActionMessage != "")
    {
        if (Player != None)
        {
            ActionMessage = class'Utils.StringUtils'.static.Format(ActionMessage, Player.GetLastName());
        }
        class'Utils.LevelUtils'.static.TellAdmins(self.Level, ActionMessage, Player.GetPC());
    }

    // Append the player's id
    if (Player != None)
    {
        AdminCommand = AdminCommand $ " " $ self.GetPlayerAMId(Player);
    }

    if (!class'Julia.Utils'.static.AdminModCommand(self.Level, AdminCommand, self.Locale.Translate("ServerString"), ""))
    {
        // Show a warning upon a failure
        if (Player != None)
        {
            class'Utils.LevelUtils'.static.TellAdmins(
                self.Level, 
                self.Locale.Translate("AdminActionMessage", AdminCommand, Player.GetLastName()),
                Player.GetPC()
            );
        }
    }
}

/**
 * Return the player's AdminMod player id
 * 
 * @param   class'Julia.Player' Player
 * @return  int
 */
protected function int GetPlayerAMId(Julia.Player Player)
{
    local SwatGame.SwatMutator SM;

    foreach DynamicActors(class'SwatGame.SwatMutator', SM)
    {
        if (SM.IsA('AMPlayerController'))
        {
            if (AMMod.AMPlayerController(SM).PC == Player.GetPC())
            {
                return AMMod.AMPlayerController(SM).id;
            }
        }
    }
    return -1;
}

/**
 * Return the number of Player's teamhits performed with specific weapons WeaponNames
 * WeaponNames is a string array that must contain case-insensitive weapon friendly names (Colt M4A1 Carbine, 9mm SMG)
 * 
 * @param   class'Julia.Player' Player
 * @param   array<string> WeaponNames
 * @return  int
 */
static function int GetPlayerTeamHits(Julia.Player Player, array<string> WeaponNames)
{
    local int i, TeamHits;
    local array<Julia.Weapon> Weapons;

    Weapons = Player.GetWeapons();

    for (i = 0; i < Weapons.Length; i++)
    {
        if (class'Utils.ArrayUtils'.static.Search(WeaponNames, Weapons[i].GetFriendlyName(), true) >= 0)
        {
            TeamHits += Weapons[i].GetTeamHits();
        }
    }

    return TeamHits;
}

event Destroyed()
{
    if (self.Core != None)
    {
        self.Core.GetDispatcher().UnbindAll(self);

        self.Core.UnregisterInterestedInEventBroadcast(self);
        self.Core.UnregisterInterestedInInternalEventBroadcast(self);
        self.Core.UnregisterInterestedInMissionEnded(self);
        self.Core.UnregisterInterestedInPlayerNameChanged(self);
        self.Core.UnregisterInterestedInPlayerTeamSwitched(self);
        self.Core.UnregisterInterestedInPlayerAdminLogged(self);
        self.Core.UnregisterInterestedInPlayerDisconnected(self);
        self.Core.UnregisterInterestedInPlayerVoiceChanged(self);
    }
    
    self.DropAllActions();

    while (self.BalanceList.Length > 0)
    {
        self.BalanceList[0] = None;
        self.BalanceList.Remove(0, 1);
    }

    while (self.ProtectedNames.Length > 0)
    {
        self.ProtectedNames.Remove(0, 1);
    }

    Super.Destroyed();
}

defaultproperties
{
    Title="Julia/Admin";
    Version="1.1.0";
    LocaleClass=class'Locale';

    AutoBalanceAdminPresent=true;
    AutoBalanceAction="none";
    AutoBalanceTime=20;

    ProtectNamesAction="kick";
    ProtectNamesActionTime=60;
    ProtectNamesActionWarnings=5;

    DisallowNamesAction="kick";
    DisallowNamesActionTime=60;
    DisallowNamesActionWarnings=5;

    DisallowWordsAction="none";
}

/* vim: set ft=java: */