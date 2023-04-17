/// @function scrCalculateTotalAttack()
/// @desc Calculates the total attack of the hero, taking base stats, items, buffs and other status effects into account and places the result in heroTotalAtk variable

function scrCalculateTotalAttack() 
{
	var allowTapDamageBoosting;
	
	if tapDamageBonusMod > 0.1 //we've tapped at the right time, so allow boosting this further with the Turbo Controller item	
		allowTapDamageBoosting = true	
	else
	{
	    allowTapDamageBoosting = false
	    chargeStrike1TurnsWithoutMissingTap = 0
	}

	heroTotalAtk = 0

	var totalEAtk = 0
	var totalEAtkMod = 0
	var totalEAtkAreaMod = 0

	//gather that attack-affecting modifiers from all 5 items you've equipped
	for (var i = 0; i < 5; i += 1)
	{
	    totalEAtk += eAtk[i]
	    totalEAtkMod += eAtkMod[i]
    
	    if room != MainMenu //do the following only in battle
	    {
	        if eConditionalAtkMod[i] != 0
	        {        
	            if heroHp/heroTotalMaxHp <= eAtkModHpCondition[i]
	            totalEAtkMod += eConditionalAtkMod[i]
	        }
        
	        if eWaterAreaAtkBoost[i] != 0
	        totalEAtkAreaMod += eWaterAreaAtkBoost[i]
        
	        if eFullHpAtkMod[i] != 0
	        {
	            if heroHp = heroTotalMaxHp
	            totalEAtkMod += eFullHpAtkMod[i]
	        }
        
	        if eNoDamageKillAtkMod[i] != 0 //we're assuming you can only have one item equipped that affects this
	        {
	            var tempAtkMultiplier = min(enemiesSlainInRowWithoutDamage, eNoDamageKillAtkLimit[i])        
	            totalEAtkMod += (eNoDamageKillAtkMod[i]*tempAtkMultiplier)
	        }
        
	        if allowTapDamageBoosting
	        tapDamageBonusMod += eTapDamageMod[i]
	    }       
	}

	//the base attack power after equipment modifiers and skill base power have been factored in
	heroTotalAtk = round(((heroAtk + totalEAtk)*(1 + totalEAtkMod + totalEAtkAreaMod + stackingAtkMod + abilityAtkMod))*(1 + tapDamageBonusMod))

	//Since the formula accounting for all previous modifiers is already long, we'll go through the skill-specific modifiers one by one

	if hpDependentAttackOn
	{
	    var atkBoostByHp = (heroHp/heroTotalMaxHp)*0.4 //the change interval is 40%    
	    atkBoostByHp = 1 + heroTotalMaxAttackBoostByFullHp - 0.4 + atkBoostByHp //first set the range for this modifier, e.g. 0.8 to 1.2x or 0.9 to 1.3x, then add the effect of current hp
	    heroTotalAtk = round(heroTotalAtk*atkBoostByHp)
	}

	heroTotalAtk = round(heroTotalAtk*powerUpMod) //Power Up skill has been used

	if gambleSkillOn //factor in the effects of the Gamble skill
	{
	    if tapDamageBonusLevel = 2 //tap damage boost has been done perfectly	    
	        heroTotalAtk = round(heroTotalAtk*gambleAtkMod) 
	    else //missed tap damage boost
	        heroTotalAtk = round(heroTotalAtk*0.25)	    
    
	    gambleSkillOn = false
	}	

	if attackGamble //factor in the effect of the Dice item
	{
	    var luckBoost = (1 - power(0.99,heroTotalLuck))*2
	    var diceDamageBoostMod = 1 + round(random(5 + luckBoost))
		
	    if diceDamageBoostMod >= 6
	    diceDamageBoostMod = 6
    
	    heroTotalAtk *= (0.5 + diceDamageBoostMod*0.25)
	}

	if heroTotalAtk < 0.1
	heroTotalAtk = 0
}
