//show_message("Calculate total atk")
//ATTACK

if tapDamageBonusMod > 0.1 //we've tapped at the right time, so allow boosting this further with turbo controller
{
    allowTapDamageBoosting = true
}
else
{
    allowTapDamageBoosting = false
    chargeStrike1TurnsWithoutMissingTap = 0
}

heroTotalAtk = 0

totalEAtk = 0
totalEAtkMod = 0
totalEAtkAreaMod = 0

for (i = 0; i < 5; i += 1)
{
    totalEAtk += eAtk[i]
    totalEAtkMod += eAtkMod[i]
    
    if room != MainMenu //do the following only in battle
    {
        if eConditionalAtkMod[i] != 0
        {        
            if heroHp/heroTotalMaxHp <= eAtkModHpCondition[i]
            totalEAtkMod += eConditionalAtkMod[i]
            //TODO: Check condition type
        }
        
        if eWaterAreaAtkBoost[i] != 0 //UNUSED
        totalEAtkAreaMod += eWaterAreaAtkBoost[i]
        
        if eFullHpAtkMod[i] != 0
        {
            if heroHp = heroTotalMaxHp
            totalEAtkMod += eFullHpAtkMod[i]
        }
        
        if /*killCountAttackBoostOn and */eNoDamageKillAtkMod[i] != 0 //assuming you can only have one item equipped that affects this
        {
            tempAtkMultiplier = min(enemiesSlainInRowWithoutDamage, eNoDamageKillAtkLimit[i])
        
            totalEAtkMod += (eNoDamageKillAtkMod[i]*tempAtkMultiplier)
            //show_message("Boost atk by " +string(eNoDamageKillAtkMod[i]) +" x " + string(enemiesSlainInRowWithoutDamage))
        }
        
        if allowTapDamageBoosting
        tapDamageBonusMod += eTapDamageMod[i]
    }       
}

if room = MainMenu
{
    stackingAtkMod = 0
    abilityAtkMod = 0
    tapDamageBonusMod = 0
}

heroTotalAtk = round(((heroAtk + totalEAtk)*(1 + totalEAtkMod + totalEAtkAreaMod + stackingAtkMod + abilityAtkMod))*(1+tapDamageBonusMod))

if battleWon or room = MainMenu //don't calculate these boosts if you're in the menu
exit

if hpDependentAttackOn
{
    atkBoostByHp = (heroHp/heroTotalMaxHp)*0.4 //the change interval is 40%
    
    atkBoostByHp = 1 + heroTotalMaxAttackBoostByFullHp - 0.4 + atkBoostByHp //first set the interval, e.g. 0.8 to 1.2x or 0.9 to 1.3x, then add the effect of current hp
    
    //show_message("atk boost by hp: "+string(atkBoostByHp))
    
    heroTotalAtk = round(heroTotalAtk*atkBoostByHp)
}

heroTotalAtk = round(heroTotalAtk*powerUpMod) //power up skill

if gambleSkillOn
{
    if tapDamageBonusLevel = 2//allowTapDamageBoosting //timed tap correctly
    {
        heroTotalAtk = round(heroTotalAtk*gambleAtkMod) //gamble skill
        //show_message("Timed gamble correctly")
    }
    else //missed tap damage boost
    {
        //show_message("Gamble miss")
        heroTotalAtk = round(heroTotalAtk*0.25)
    }
    
    gambleSkillOn = false
}
//else
//show_message("Gamble skill not on")

//TODO: if battleWon
if attackGamble //dice
{
    luckBoost = (1 - power(0.99,heroTotalLuck))*2
    diceDamageBoostMod = 1 + round(random(5 + luckBoost)) //+heroTotalLuckBoost
    //TODO: Luck boost on this, raise up to 2 numbers up
    if diceDamageBoostMod >= 6
    diceDamageBoostMod = 6
    
    heroTotalAtk *= (0.5 + diceDamageBoostMod*0.25)
}

/*if chargeBeamBoostingOn
{
    //allow the player to do more damage depending on whether the holdBoost succeeds
}*/

if heroTotalAtk < 0.1
heroTotalAtk = 0
