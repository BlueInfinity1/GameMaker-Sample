// NOTE: This function was created before structs were available in GameMaker, which is why we needed multiple, specialized 2D arrays to handle certain tasks

// Argument details
// arg0 - Row to check
// arg1 - Column to check

// Initialize variables and special effect checks
checkableSpecials = 0;
newSpecialEffects = 0;
currentCheckStartingPointIndex = pointValueIndex;

// Sound effect flags
playMatch3Sound = false;
playMatch4Sound = false;
playMatch5Sound = false;
playMatchCrossSound = false;
playObjectiveCompletedSound = false;
playTargetSquareSound = false;

// Save initial grid state and reset grids
for (i = leftmostColumn; i <= rightmostColumn; i++) {
    for (j = topRow; j <= bottomRow; j++) {
        gemStorage[i, j] = gemGrid[i, j];
        protectionGrid[i, j] = 0;
        potentialMatchGrid[i, j] = 0;
        newlyCreatedJokers[i, j] = 0;
        pointIndexGrid[i, j] = -1;
    }
}

// --- Column Match Check ---
if (argument0 > -0.1) {
    givenRowToCheck = argument0;
    lowestRowToCheck = max(argument0 - 4, topRow);
    highestRowToCheck = min(argument0 + 4, bottomRow);

    for (i = leftmostColumn; i <= rightmostColumn; i++) {
        consecutiveJokerCount = 0;
        scrInitializeColumnMatchCheck(lowestRowToCheck);

        for (j = lowestRowToCheck + 1; j <= highestRowToCheck; j++) {
            if ((gemGrid[i, j] == trackedColor || gemGrid[i, j] == JOKER_INDEX) && spaceGrid[i, j] < 0.1) {
                sameGems++;
                consecutiveJokerCount += (gemGrid[i, j] == JOKER_INDEX) ? 1 : 0;
            } else {
                // Handle matches of 3, 4, 5, or more
                if (sameGems == 3) {
                    scrHandleMatch3(i, j, "vertical");
                } else if (sameGems == 4) {
                    scrHandleMatch4(i, j, "vertical");
                } else if (sameGems >= 5) {
                    scrHandleMatch5Plus(i, j, "vertical", sameGems);
                }
                scrInitializeColumnMatchCheck(j);
            }
        }

        // Final check for any match chain at the end of the column
        if (sameGems == 3) {
            scrHandleMatch3(i, highestRowToCheck, "vertical");
        } else if (sameGems == 4) {
            scrHandleMatch4(i, highestRowToCheck, "vertical");
        } else if (sameGems >= 5) {
            scrHandleMatch5Plus(i, highestRowToCheck, "vertical", sameGems);
        }
    }
}

// --- Row Match Check ---
if (argument1 > -0.1) {
    givenColumnToCheck = argument1;
    lowestColumnToCheck = max(argument1 - 4, leftmostColumn);
    highestColumnToCheck = min(argument1 + 4, rightmostColumn);

    for (j = topRow; j <= bottomRow; j++) {
        consecutiveJokerCount = 0;
        scrInitializeRowMatchCheck(lowestColumnToCheck);

        for (i = lowestColumnToCheck + 1; i <= highestColumnToCheck; i++) {
            if ((gemGrid[i, j] == trackedColor || gemGrid[i, j] == JOKER_INDEX) && spaceGrid[i, j] < 0.1) {
                sameGems++;
                consecutiveJokerCount += (gemGrid[i, j] == JOKER_INDEX) ? 1 : 0;
            } else {
                // Handle matches of 3, 4, 5, or more
                if (sameGems == 3) {
                    scrHandleMatch3(i, j, "horizontal");
                } else if (sameGems == 4) {
                    scrHandleMatch4(i, j, "horizontal");
                } else if (sameGems >= 5) {
                    scrHandleMatch5Plus(i, j, "horizontal", sameGems);
                }
                scrInitializeRowMatchCheck(i);
            }
        }

        // Final check for any match chain at the end of the row
        if (sameGems == 3) {
            scrHandleMatch3(highestColumnToCheck, j, "horizontal");
        } else if (sameGems == 4) {
            scrHandleMatch4(highestColumnToCheck, j, "horizontal");
        } else if (sameGems >= 5) {
            scrHandleMatch5Plus(highestColumnToCheck, j, "horizontal", sameGems);
        }
    }
}

// --- Cross-Match Check ---
for (i = leftmostColumn; i <= rightmostColumn; i++) {
    for (j = topRow; j <= bottomRow; j++) {
        if (matchGrid[i, j] > 1.9 && scrVerifyCrossMatch(i, j)) {
            // Handle cross-matches and special effects
            scrHandleCrossMatch(i, j);
        }
    }
}

// --- Cleanup ---
for (i = leftmostColumn; i <= rightmostColumn; i++) {
    for (j = topRow; j <= bottomRow; j++) {
        if (matchGrid[i, j] > 0.9) {
            // Handle matched gem removal and special effects
            scrRemoveMatchedGem(i, j);
        }
    }
}

// --- Special Effects ---
for (i = 0; i < checkableSpecials; i++) {
    scrUseGemSpecialEffect(checkListCols[i], checkListRows[i], -1, checkListGems[i]);
}

for (i = 0; i < newSpecialEffects; i++) {
    scrUpdateGemGridSpecials(effectUpdateListCols[i], effectUpdateListRows[i], effectUpdateList[i]);
    scrCreateSpecialGemCreationEffect(effectUpdateListCols[i], effectUpdateListRows[i], effectUpdateList[i]);
}

// --- Sound Effects ---
if (soundOn) {
    scrPlaySoundEffects();
}
