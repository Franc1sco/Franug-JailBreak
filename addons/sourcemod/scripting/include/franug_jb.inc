// JAILBREAK natives by Franc1sco franug


// Teams index for JAILBREAK plugin
#define JB_GUARDS 1
#define JB_PRISIONERS 2
#define JB_BOTH 3


/**
 * Add a Award to the main plugin.
 *
 * @param name            Award name.
 * @param price           Award Price.
 * @param teamallowed            Team allowed for use this award.
 * 
 * @noreturn			       
 */
native JB_AddAward(const String:name[], price, teamallowed);

/**
 * Select a special round to do this round.
 *
 * @param name            Round name.
 * 
 * @noreturn			       
 */
native JB_ChooseRound(const String:name[]);

/**
 * Called when a Award has been bought.
 *
 * @param client            Client that bought the award.
 * @param price           Award Bought.		       
 */
forward JB_OnAwardBought( client, const String:awardbought[]);

/**
 * Remove a Award to the main plugin.
 *
 * @param name            Award name.
 * 
 * @noreturn			       
 */
native JB_RemoveAward(const String:name[]);

/**
 * Set as special class (can´t buy awards) a player.
 *
 * @param client            Client target.
 * @param special            Set true or false the state of "special class".
 * 
 * @noreturn			       
 */
native JB_SetSpecial(client, bool:special);

/**
 * Check if a player is a special class.
 *
 * @param client            client index
 * 
 * @return			        True if Special class, false if not.
 */
native bool:JB_GetSpecial(client);

/**
 * Set credits to a client.
 *
 * @param client            Client target.
 * @param credits            Number of credit for set.
 * 
 * @noreturn			       
 */
native JB_SetCredits(client, credits);

/**
 * Check if a player is a special class.
 *
 * @param client            Client target.
 * 
 * @return			        Return current credits of the target
 */
native JB_GetCredits(client);

/**
 * Give FreeDay to a player.
 *
 * @param client            Client target.
 * 
 * @noreturn			       
 */
native JB_GiveFD(client);

/**
 * Check if a player is FD.
 *
 * @param client            client index.
 * 
 * @return			        True if FD, false if not.
 */
native bool:JB_GetFD(client);

/**
 * Sent translations to the main plugin.
 *
 * @param client            File with translations.
 * 
 * @noreturn			       
 */
native JB_LoadTranslations(const String:langfile[]); 

/**
 * Check if a player is a special class.
 *
 * @param CurrentRound           String to store the name of current round.
 * 
 * @return			        Return true if a round has been selected, false if not.
 */
native bool:JB_GetRound(String:CurrentRound[]);
