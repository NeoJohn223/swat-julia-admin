class Locale extends Julia.Locale;

/**
 * Copyright (c) 2014-2015 Sergei Khoroshilov <kh.sergei@gmail.com>
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

var config string ServerString;

var config string AuthCommandUsage;
var config string AuthCommandDescription;

var config string AdminLoginMessage;

var config string AdminWelcomeMessage;
var config string AdminWelcomeListOne;
var config string AdminWelcomeListNone;
var config string AdminWelcomeListMany;

var config string ProtectNamesWarningMessage;
var config string ProtectNamesPunishMessage;
var config string ProtectNamesNoChatMessage;

var config string ProtectNamesResponseAccepted;
var config string ProtectNamesResponseRejected;
var config string ProtectNamesResponseInvalid;

var config string DisallowNamesWarningMessage;
var config string DisallowNamesPunishMessage;

var config string DisallowWordsWarningMessage;
var config string DisallowWordsAdminMessage;
var config string DisallowWordsPunishMessage;

var config string AutoBalanceWarning;
var config string AutoBalanceMessage;
var config string AutoBalancePunishMessage;

var config string FriendlyFireMessage;
var config string FriendlyFireNoWeaponMessage;
var config string FriendlyFirePunishMessage;

var config string AdminActionFailure;

var config string ActionColor;
var config string MessageColor;

defaultproperties
{
    ServerString="The Server";

    AuthCommandUsage="!%1 password";
    AuthCommandDescription="Allows you to use a protected name.";

    AdminLoginMessage="[b]%1[\\b] logged in (%2).";

    AdminWelcomeMessage="Welcome to duty, [b]%1[\\b]!";
    AdminWelcomeListOne="There is only one admin logged on.\\nThat's [b]%1[\\b].";
    AdminWelcomeListNone="There are no other admins logged on.";
    AdminWelcomeListMany="There are %2 admins logged on.\\nThey are: [b]%1[\\b].";

    ProtectNamesWarningMessage="You are using a protected nickname.\\nPlease authenticate yourself using the !auth command.";
    ProtectNamesPunishMessage="Punishing [b]%1[\\b] for using a protected nickname.";
    ProtectNamesNoChatMessage="Please authenticate yourself to get your chat unlocked.";

    ProtectNamesResponseAccepted="You are now authorised to use the protected nickname.";
    ProtectNamesResponseRejected="Invalid password. Please try again.";
    ProtectNamesResponseInvalid="Authentication is not required.";

    DisallowNamesWarningMessage="You are using a disallowed nickname.\\nPlease change it to an appropriate one!";
    DisallowNamesPunishMessage="Punishing [b]%1[\\b] for using a disallowed name.";

    DisallowWordsWarningMessage="Your language is inappropriate!";
    DisallowWordsAdminMessage="[b]%1[\\b] said: %2";
    DisallowWordsPunishMessage="Punishing [b]%1[\\b] for using foul language.";

    AutoBalanceWarning="Teams will be auto-balanced in %1 seconds.";
    AutoBalanceMessage="[b]%1[\\b] moved [b]%2[\\b] to the other team.";
    AutoBalancePunishMessage="Punishing [b]%1[\\b] for unbalancing teams.";

    FriendlyFireMessage="[b]%1[\\b] team hit [b]%2[\\b] with a %3.";
    FriendlyFireNoWeaponMessage="[b]%1[\\b] team hit [b]%2[\\b].";
    FriendlyFirePunishMessage="Punishing [b]%1[\\b] for friendly fire.";

    AdminActionFailure="Failed to issue [b]%1[\\b] against [b]%2[\\b].";

    ActionColor="FF00FF";
    MessageColor="FFA800";
}

/* vim: set ft=java: */
