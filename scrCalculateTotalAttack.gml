/// @function scrCalculateTotalAttack()
/// @desc Calculates the total attack of the hero, factoring in base stats, items, buffs, and status effects.
///       The result is stored in the `heroTotalAtk` variable.

function scrCalculateTotalAttack() {
    // Initialize variables
    var allowTapDamageBoosting = false;

    // Check if tap damage boosting is allowed
    if (tapDamageBonusMod > 0.1) {
        allowTapDamageBoosting = true;
    } else {
        chargeStrike1TurnsWithoutMissingTap = 0;
    }

    // Reset hero total attack
    heroTotalAtk = 0;

    // Initialize equipment modifiers
    var totalEAtk = 0;
    var totalEAtkMod = 0;
    var totalEAtkAreaMod = 0;

    // Gather attack-affecting modifiers from equipped items
    for (var i = 0; i < 5; i++) {
        totalEAtk += eAtk[i];
        totalEAtkMod += eAtkMod[i];

        // Apply conditional modifiers only in battle
        if (room != MainMenu) {
            // Conditional attack modifier based on HP
            if (eConditionalAtkMod[i] != 0 && heroHp / heroTotalMaxHp <= eAtkModHpCondition[i]) {
                totalEAtkMod += eConditionalAtkMod[i];
            }

            // Area-specific attack modifier
            if (eWaterAreaAtkBoost[i] != 0) {
                totalEAtkAreaMod += eWaterAreaAtkBoost[i];
            }

            // Full HP attack bonus
            if (eFullHpAtkMod[i] != 0 && heroHp == heroTotalMaxHp) {
                totalEAtkMod += eFullHpAtkMod[i];
            }

            // No damage kill attack bonus
            if (eNoDamageKillAtkMod[i] != 0) {
                var tempAtkMultiplier = min(enemiesSlainInRowWithoutDamage, eNoDamageKillAtkLimit[i]);
                totalEAtkMod += eNoDamageKillAtkMod[i] * tempAtkMultiplier;
            }

            // Tap damage bonus
            if (allowTapDamageBoosting) {
                tapDamageBonusMod += eTapDamageMod[i];
            }
        }
    }

    // Calculate base attack after equipment modifiers
    heroTotalAtk = round(
        ((heroAtk + totalEAtk) * (1 + totalEAtkMod + totalEAtkAreaMod + stackingAtkMod + abilityAtkMod)) * 
        (1 + tapDamageBonusMod)
    );

    // Apply skill-specific modifiers
    if (hpDependentAttackOn) {
        var atkBoostByHp = (heroHp / heroTotalMaxHp) * 0.4;
        atkBoostByHp = 1 + heroTotalMaxAttackBoostByFullHp - 0.4 + atkBoostByHp;
        heroTotalAtk = round(heroTotalAtk * atkBoostByHp);
    }

    // Power-Up skill modifier
    heroTotalAtk = round(heroTotalAtk * powerUpMod);

    // Gamble skill effects
    if (gambleSkillOn) {
        if (tapDamageBonusLevel == 2) {
            heroTotalAtk = round(heroTotalAtk * gambleAtkMod);
        } else {
            heroTotalAtk = round(heroTotalAtk * 0.25);
        }
        gambleSkillOn = false;
    }

    // Dice item effect
    if (attackGamble) {
        var luckBoost = (1 - power(0.99, heroTotalLuck)) * 2;
        var diceDamageBoostMod = 1 + round(random(5 + luckBoost));
        diceDamageBoostMod = min(diceDamageBoostMod, 6);
        heroTotalAtk *= (0.5 + diceDamageBoostMod * 0.25);
    }

    // Ensure attack value is non-negative
    if (heroTotalAtk < 0.1) {
        heroTotalAtk = 0;
    }
}
