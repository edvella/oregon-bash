#!/bin/bash

# Oregon Trail version based on
# PROGRAMMING REVISIONS BY DON RAWITSCH - 3/27/75
# MINNESOTA EDUCATIONAL COMPUTING CONSORTIUM STAFF

purchaseValue=-1

animalPower=0
ammoLeft=0
clothingLeft=0
foodLeft=0
suppliesLeft=0

startingBudget=700
cashLeft=$startingBudget
distanceCovered=0
turnNumber=0
isInjured=false
isSick=false
southPassClearanceFlag=0
blueMountainClearanceFlag=0
southPassMileageFlag=0
canVisitFort=false
fortSpending=0
shootingScore=0

turnDates=("April 12", "April 26", "May 10", "May 24", "June 7", "June 21", \
           "July 5", "July 19", "August 2", "August 16", "August 31", \
           "September 13", "September 27", "October 11", "October 25", \
           "November 8", "November 22")

instructions() {
    echo;echo
    echo "This program simulates a trip over the Oregon Trail from"
    echo "Independence, Missouri to Oregon City, Oregon in 1847."
    echo "Your family of five will cover the 2000 mile Oregon Trail"
    echo "in 5-6 months --- if you make it alive."
    echo
    echo "You had saved \$900 to spend for the trip, and you've just"
    echo "   paid \$200 for a wagon."
    echo "You will need to spend the rest of your money on the"
    echo "   following items:"
    echo
    echo "     Oxen - you can spend \$200-\$300 on your team."
    echo "            The more you spend, the faster you'll go"
    echo "               because you'll have better animals."
    echo
    echo "     Food - the more you have, the less chance there"
    echo "               is of getting sick."
    echo
    echo "     Ammunition - \$1 buys a belt of 50 bullets."
    echo "            You will need bullets for attacks by animals."
    echo
    echo "     Clothing - this is especially important for the cold"
    echo "               weather you will encounter when crossing"
    echo "               the mountains."
    echo
    echo "     Miscellaneous supplies - this includes medicine and"
    echo "               other things you will need for sickness"
    echo "               and emergency repairs."
    echo;echo
    echo "You can spend all your money before you start your trip -"
    echo "or you can save some of your cash to spend at forts along"
    echo "the way when you run low.  However, items cost more at"
    echo "the forts.  You can also go hunting along the way to get"
    echo "more food."
    echo "Whenever you have to use your trusty rifle along the way,"
    echo "you will see words: type BANG.  The faster you type"
    echo "in the word 'BANG' and hit the 'Return' key, the better"
    echo "luck you'll have with your gun."
    echo
    echo "When asked to enter money amounts, don't use a '\$'."
    echo
    echo "Good luck!!!"
}

rangedPurchase() {
    purchaseValue=-1
    prompt=$1
    minRequired=$2
    maxAllowed=$3
    
    until [ $purchaseValue -gt -1 ]
    do
        echo -n "How much do you want to spend on $prompt? "
        read x
        if [ $x -lt $minRequired ]
            then echo "Not enough";
            else if [ $x -gt $maxAllowed ]
                then echo "Too much"
                else purchaseValue=$x
            fi
        fi
    done
}

purchase() {
    purchaseValue=-1
    prompt=$1
    
    until [ $purchaseValue -ge 0 ]
    do
        echo -n "How much do you want to spend on $prompt? "
        read purchaseValue
        if [ $purchaseValue -lt 0 ];then echo "Impossible";fi
    done
}

preparations() {    
    preparationsComplete=false
    until [ $preparationsComplete == true ]
    do
        echo;echo
        rangedPurchase "your oxen team" 200 300; animalPower=$purchaseValue
        purchase "food"; foodLeft=$purchaseValue
        purchase "ammunition"; ammoLeft=$purchaseValue
        purchase "clothing"; clothingLeft=$purchaseValue
        purchase "miscellaneous supplies"; suppliesLeft=$purchaseValue
        
        cashLeft=$((startingBudget - animalPower - foodLeft - ammoLeft - clothingLeft \
                - suppliesLeft))
            
        if [ $cashLeft -lt 0 ]
          then echo "You overspent--you only had \$$startingBudget to spend. Buy again."
          else preparationsComplete=true
        fi
        
    done
    
    ((ammoLeft*=50))
    echo "After all your purchases, you now have $cashLeft dollars left."
    echo
    echo "Monday, March 29, 1847"
    echo
}

init() {
    canVisitFort=false
    isInjured=false
    isSick=false
    southPassClearanceFlag=0
    blueMountainClearanceFlag=0
    distanceCovered=0
    southPassMileageFlag=0
    turnNumber=0
    
    preparations
}

printDate() {
    echo
    echo "Monday ${turnDates[turnNumber]} 1847"
    echo
}

negativeValueCheck() {
    if [ $foodLeft -lt 0 ]; then foodLeft=0; fi
    if [ $ammoLeft -lt 0 ]; then ammoLeft=0; fi
    if [ $clothingLeft -lt 0 ]; then clothingLeft=0; fi
    if [ $suppliesLeft -lt 0 ]; then suppliesLeft=0; fi
}

printResourceTable() {
    negativeValueCheck
    if [ $cashLeft -lt 0 ]; then cashLeft=0; fi
    printf "%-15s%-15s%-15s%-15s%-15s\n" "Food" "Bullets" "Clothing" "Misc. Supp." "Cash"
    printf "%-15s%-15s%-15s%-15s%-15s\n" "${foodLeft}" "${ammoLeft}" "${clothingLeft}" "${suppliesLeft}" "${cashLeft}"
}

finalTurn() {
    ((twoWeekFraction=((2040 - $mileageAtPreviousTurn) * 1000) / ($distanceCovered - $mileageAtPreviousTurn)))
    foodLeft=$(($foodLeft + (1000 - $twoWeekFraction) * (8 + 5 * $mealSize) / 1000))
    
    printf "\nYou\a finally arri\aved at Ore\agon City\a\n"
    printf "after\a 2040 long miles\a---hooray!!\a!!\n\n"
    
    twoWeekFraction=$(($twoWeekFraction * 14 / 1000))
    turnNumber=$(($turnNumber * 14 + $twoWeekFraction))
    ((twoWeekFraction++))
    echo $(date -d "18470329 $turnNumber days" +'%A %B %d %Y')
    echo
    printResourceTable
    echo
    echo "President James K. Polk sends you his"
    echo "      heartiest congratulations"
    echo
    echo "           and wishes you a prosperous life ahead"
    echo
    echo "                      at your new home."
    exit 0
}

checkIfDoctorNeeded() {
    if $isSick || $isInjured
        then {
            ((cashLeft-=20))
            echo "Doctor's bill is \$20"
            isInjured=false;isSick=false
        }
    fi
}

printMileage() {
    if [ $southPassMileageFlag == 1 ]
        then echo "Total mileage is 950"; southPassMileageFlag=0
        else echo "Total mileage is ${distanceCovered}"
    fi
}

fortShop() {
    echo -n "$1 "
    read fortSpending
    
    if [ $fortSpending -gt 0 ]
        then if [ $cashLeft -ge $fortSpending ]
            then ((cashLeft-=$fortSpending));
            else echo "You don't have that much--keep your spending down."; fortSpending=0
        fi
    fi
    
    ((fortSpending=$fortSpending * 2 / 3))
}

slowTurn() {
    ((distanceCovered-=45))
}

stopAtFort() {
    echo "Enter what you wish to spend on the following"
    fortShop "food";((foodLeft+=fortSpending))
    fortShop "ammunition";((ammoLeft+=fortSpending * 50))
    fortShop "clothing";((clothingLeft+=fortSpending))
    fortShop "miscellaneous supplies";((suppliesLeft+=fortSpending))
    
    slowTurn
}

shoot() {
    echo "Type bang"
    startTime=$(date +%s)
    read -t 7 -N 4
    endTime=$(date +%s)
    echo
    
    if [ $REPLY == "bang" ]
        then ((shootingScore=$endTime - startTime))
        else ((shootingScore=7))
    fi
}

hunt() {
    if [ $ammoLeft -lt 40 ]
        then {
            echo "Tough---you need more bullets to go hunting."
            canVisitFort=true
            playerMove
        }
        else {
            slowTurn
            shoot
            
            if [ $shootingScore -le 1 ]
                then {
                    printf "Ri\aght betwee\an the eye\as---you got a\a big one!!\a!!\n"
                    ((foodLeft+=52+($RANDOM % 6)))
                    ((ammoLeft-=10+($RANDOM % 4)))
                }
                else {
                    if [ $(( $RANDOM % 100 )) -lt $(( 13 * $shootingScore )) ]
                        then echo "Sorry---no luck today."
                        else {
                            ((foodLeft+=48-(2 * $shootingScore)))
                            echo "Nice shot---right through the neck--feast tonight!!"
                            ((ammoLeft-=10+(3 * $shootingScore)))
                        }
                    fi
                }
            fi
        }
    fi
}

deathSequence() {
    echo
    echo "Due to your unfortunate situation, there are a few"
    echo "formalities we must go through."
    echo
    echo "Would you like a minister?"
    read
    echo "Would you like a fancy funeral?"
    read
    echo "Would you like us to inform your next of kin?"
    read playerAnswer
    if [ $playerAnswer != "yes" ]
        then echo "Your aunt Nellie in St. Louis is anxious to hear."
    fi
    echo "We thank you for this information and we are sorry you"
    echo "didn't make it to the great territory of Oregon."
    echo "Better luck next time."
    echo
    echo
    echo -e "\033[30CSincerely"
    echo
    echo -e "\033[17CThe Oregon City Chamber of Commerce"
    exit 0
}

playerMove() {
    if $canVisitFort
        then {
            canVisitFort=false
            echo "Do you want to (1) stop at the next fort, (2) hunt, or (3) continue"
            read playerChoice
        }        
        else {
            isValid=false
            until $isValid
            do            
                echo "Do you want to (1) hunt, or (2) continue"
                read playerChoice
                if [ $playerChoice == 1 ]
                    then {
                        playerChoice=2
                        if [ $ammoLeft -lt 40 ]
                            then echo "Tough---you need more bullets to go hunting."
                            else isValid=true
                        fi
                    }
                    else playerChoice=3; isValid=true
                fi
            done
            canVisitFort=true
        }
    fi
    
    case $playerChoice in
        1)
            stopAtFort
            ;;
        2)
            hunt
            ;;
    esac
}

foodCheck() {
    if [ $foodLeft -lt 13 ] 
        then 
            echo "You ran out of food and starved to death"
            deathSequence
    fi
}

eat() {
    isEatingCompleted=false
    until $isEatingCompleted
    do
        echo "Do you want to eat (1) poorly  (2) moderately"
        echo -n "or (3) well? "
        read mealSize
        if [ $mealSize -ge 1 ] && [ $mealSize -le 3 ]
            then if [ $foodLeft -ge $((8 + 5 * $mealSize)) ]
                then {
                    foodLeft=$((foodLeft - 8 - (5 * $mealSize)))
                    isEatingCompleted=true
                }
                else echo "You can't eat that well."
            fi
        fi
    done
}

attackOutcome() {
    if [ $areRidersFriendly == 1 ]
        then echo "todo friendly"
        else {
            echo "Riders were hostile--check for losses."
            if [ $ammoLeft -lt 0 ]
                then {
                    echo "You ran out of bullets and got massacred by the riders."
                    deathSequence
                }
            fi
        }
    fi
}

ridersShootingResult() {
    if [ $shootingScore -le 1 ]
        then echo "Nice shooting---you drove them off."
        else if [ $shootingScore -gt 4 ]
            then {
                echo "Lousy shot---you got knifed."
                isInjured=true
                echo "You have to see ol' Doc Blanchard."
            }
            else echo "Kinda slow with your Colt .45."
        fi
    fi
    attackOutcome
}

hostileRiders() {
    case $tactic in 
    
        1)
            ((distanceCovered+=20))
            ((suppliesLeft-=15))
            ((ammoLeft-=150))
            ((animalPower-=40))
            attackOutcome
            ;;

        2)
            shoot
            ammoLeft=$(($ammoLeft - $shootingScore * 40 - 80 ))
            ridersShootingResult
            ;;
            
        3)
            if [ $(( $RANDOM % 10 )) -gt 8 ]
                then echo "They did not attack."
                else {
                    ((ammoLeft-=150))
                    ((suppliesLeft-=15))
                    attackOutcome
                }  
            fi
            ;;
            
        4)
            shoot
            ammoLeft=$(($ammoLeft - $shootingScore * 30 - 80 ))
            ((distanceCovered-=25))
            ridersShootingResult
            ;;
    esac
}

friendlyRiders() {
    case $tactic in 
    
        1)
            ((distanceCovered+=15))
            ((animalPower-=10))
            ;;

        2)
            ((distanceCovered-=5))
            ((ammoLeft-=100))
            ;;
            
        4)
            ((distanceCovered-=20))
            ;;
    esac
    
    attackOutcome
}

riders() {
    distanceFactor=$(( ($distanceCovered / 100 - 4) ** 2))
    if [ $(( $RANDOM % 10 )) -le $(( ($distanceFactor + 72) / ($distanceFactor + 12) - 1 )) ]
        then {
            echo -n "Riders ahead.  They "
            areRidersFriendly=0
            if [ $(( $RANDOM % 10 )) -ge 7 ]; then echo -n "don't "; areRidersFriendly=1; fi
            echo "look hostile."
            echo "Tactics"
            
            isTacticSelected=false
            until $isTacticSelected
            do
                echo "(1) Run  (2) Attack  (3) Continue  (4) Circle wagons"
                echo "If you run you'll gain time but wear down your oxen."
                echo "If you circle you'll lose time."
                if [ $(( $RANDOM % 10 )) -le 2 ]; then areRidersFriendly=$((1 - $areRidersFriendly)); fi
                read tactic
                if [ $tactic -ge 1 ] && [ $tactic -le 4 ]
                    then isTacticSelected=true
                fi
            done
            
            if [ $areRidersFriendly == 1 ]
                then friendlyRiders
                else hostileRiders
            fi
        }
    fi
}

deathCause() {
    echo -n "You died of "
    if $isInjured
        then echo "injuries."
        else echo "pneumonia."
    fi
    deathSequence
}

illness() {
    if [ $(($RANDOM % 100)) -ge $((10 + 35 * ($mealSize - 1))) ]
        then if [ $(($RANDOM % 100)) -ge $((100 - (40 / 4 ** ($mealSize - 1)))) ]
            then {
                echo "Serious illness---"
                echo "You must stop for medical attention."
                ((suppliesLeft-=10))
                isSick=true
            }
            else {
                echo "Bad Illness---medicine used."
                ((distanceCovered-=5))
                ((suppliesLeft-=5))
            }
        fi
        else {
            echo "Mild illness---medicine used"
            ((distanceCovered-=5))
            ((suppliesLeft-=2))
        }
    fi
    
    if [ $suppliesLeft -lt 0 ]
        then {
            echo "You ran out of medical supplies."
            deathCause
        }
        else if $isBlizzard
            then if [ $distanceCovered -le 950 ]
                then southPassClearanceFlag=1
            fi
            # todo 700?
        fi
    fi
}

coldWeather() {
    echo -n "Cold weather---BRRRRRRR!---you "
    if [ $clothingLeft -le $((22 + $RANDOM % 4)) ]
        then {
            echo -n "don't "
            isInsufficientClothing=true
        }
    fi
    echo "have enough clothing to keep you warm."
    
    if $isInsufficientClothing
        then illness
    fi       
}

banditsAttack() {
    shoot
    ammoLeft=$(($ammoLeft - 20 * $shootingScore))
    
    if [ $ammoLeft -lt 0 ]
        then {
            echo "You ran out of bullets---they get lots of cash."
            cashLeft=$(($cashLeft / 3))
            isShot=true
        }
        else {
            if [ $shootingScore -gt 1 ]
                then isShot=true
                else isShot=false
            fi
        }
    fi
    
    if $isShot
        then {
            echo "You got shot in the leg and they took one of your oxen."
            isInjured=true
            echo "Better have a doc look at your wound."
            ((suppliesLeft-=5))
            ((animalPower-=20))
        }
        else {
            echo "Quickest draw outside of Dodge City!!!"
            echo "You got 'em!"
        }
    fi
}

wildAnimalAttack() {
    shoot
    if [ $ammoLeft -gt 39 ]
        then {
            if [ $shootingScore -gt 2 ]
                then echo "Slow on the draw---they got at your food and clothes."
                else echo "Nice shootin' pardner---they didn't get much."
            fi
            ammoLeft=$(($ammoLeft - 20 * $shootingScore))
            clothingLeft=$(($clothingLeft - $shootingScore * 4))
            foodLeft=$(($foodLeft - $shootingScore * 8))
        }
        else {
            echo "You were too low on bullets--"
            echo "The wolves overpowered you."
            isInjured=true
            deathCause
        }
    fi
}

randomEvents() {
    eventCounter=0
    randomEvent=$(($RANDOM % 100))
    eventNumber=( 6 11 13 15 17 22 32 35 37 42 44 54 64 69 95 100)
    eventCompleted=false
    
    until $eventCompleted
    do
        if [ $eventCounter == 16 ] || [ ${eventNumber[$eventCounter]} -gt $randomEvent ] 
            then eventCompleted=true;
        fi
        
        ((eventCounter++))
    done
    
    case $eventCounter in
        1)
            echo "Wagon breaks down--lose time and supplies fixing it."
            distanceCovered=$(($distanceCovered - 15 - ($RANDOM % 5)))
            ((suppliesLeft-=8))
            ;;
        2)
            echo "Ox injures leg---slows you down rest of trip."
            ((distanceCovered-=25))
            ((animalPower-=20))
            ;;
        3)
            echo "Bad luck---your daughter broke her arm."
            echo "You had to stop and use supplies to make a sling."
            distanceCovered=$(($distanceCovered - 5 - ($RANDOM % 4)))
            suppliesLeft=$(($suppliesLeft - 2 - ($RANDOM % 3)))
            ;;
        4)
            echo "Ox wanders off---spend time looking for it."
            ((distanceCovered-=17))
            ;;
        5)
            echo "Your son gets lost===spend half the day looking for him."
            ((distanceCovered-=10))
            ;;
        6)
            echo "Unsafe water--lose time looking for clean spring."
            distanceCovered=$(($distanceCovered - 2 - ($RANDOM % 10)))
            ;;
        7)
            if [ $distanceCovered -gt 950 ]
                then coldWeather
                else {
                    echo "Heavy rains---time and supplies lost."
                    ((foodLeft-=10))
                    ((ammoLeft-=500))
                    ((suppliesLeft-=15))
                    distanceCovered=$(($distanceCovered - 5 - ($RANDOM % 10)))
                }
            fi
            ;;
        8)
            echo "Bandits attack."
            banditsAttack
            ;;
        9)
            echo "There was a fire in your wagon--food and supplies damaged."
            ((foodLeft-=40))
            ((ammoLeft-=400))
            suppliesLeft=$(($suppliesLeft - 3 - ($RANDOM % 8)))
            ((distanceCovered-=15))
            ;;
        10)
            echo "Lose your way in heavy fog--time is lost."
            distanceCovered=$(($distanceCovered - 10 - ($RANDOM % 5)))
            ;;
        11)
            echo "You killed a poisonous snake after it bit you."
            ((ammoLeft-=10))
            ((suppliesLeft-=5))
            if [ $suppliesLeft -lt 0 ]
                then {
                    echo "You die of snakebite since you have no medicine."
                    deathSequence
                }
            fi
            ;;
        12)
            echo "Wagon gets swamped fording river--lose food and clothes."
            ((foodLeft-=30))
            ((clothingLeft-=20))
            distanceCovered=$(($distanceCovered - 20 - ($RANDOM % 20)))
            ;;
        13)
            echo "Wild animals attack!"
            wildAnimalAttack
            ;;
        14)
            echo "Hail storm---supplies damaged."
            distanceCovered=$(($distanceCovered - 5 - ($RANDOM % 10)))
            ((ammoLeft-=200))
            suppliesLeft=$(($suppliesLeft - 4 - ($RANDOM % 3)))
            ;;
            
            # todo event 15
            
        16)
            echo "Helpful Indians show you where to find more food."
            ((foodLeft+=14))
            eventCompleted=true
            ;;
    esac
}

blizzard() {
    echo "Blizzard in mountain pass--time and supplies lost."
    isBlizzard=true
    ((foodLeft-=25))
    ((suppliesLeft-=10))
    ((ammoLeft-=300))
    distanceCovered=$(($distanceCovered - 30 - ($RANDOM % 40)))
    if [ $clothingLeft -lt $((18 + ($RANDOM % 2))) ]; then illness; fi
}

mountains() {
    if [ $distanceCovered -gt 950 ]
        then {
            if [ $(($RANDOM % 10)) -le $((9 - (($distanceCovered / 100 - 15) ** 2 + 72) / (($distanceCovered / 100 - 15) ** 2 + 12))) ]
                then {
                    echo "Rugged Mountains"
                    if [ $(($RANDOM % 10)) -gt 1 ]
                        then if [ $(($RANDOM % 100)) -gt 11 ]
                            then {
                                echo "The going gets slow."
                                distanceCovered=$(($distanceCovered - 45 - ($RANDOM % 50)))
                            }
                            else {
                                echo "Wagon damaged!---lose time and supplies."
                                ((suppliesLeft-=5))
                                ((ammoLeft-=200))
                                distanceCovered=$(($distanceCovered - 20 - ($RANDOM % 30)))
                            }
                        fi
                        else {
                            echo "You got lost---lose valuable time trying to find trail!"
                            ((distanceCovered-=60))
                        }
                    fi
                    
                    if [ $southPassClearanceFlag == 0 ]
                        then {
                            southPassClearanceFlag=1
                            if [ $(($RANDOM % 10)) -lt 8 ]
                                then blizzard
                                else {
                                    echo "You made it safely through South Pass--no snow."
                                }
                            fi
                        }
                    fi
                    
                    if [ $distanceCoverted -ge 1700 ] && [ $blueMountainClearanceFlag == 0 ]
                        then {
                            blueMountainClearanceFlag=1
                            if [ $(($RANDOM % 10)) -lt 7 ]
                                then blizzard
                            fi
                        }
                    fi
                    
                    if [ $distanceCovered -le 950 ]
                        then southPassMileageFlag=1
                    fi
                }
            fi
        }
    fi
}

gameLoop() {
    gameOver=false
    until $gameOver
    do              
        negativeValueCheck
        
        if [ $foodLeft -lt 12 ]
            then echo "You'd better do some hunting or buy food and soon!!!!"
        fi
        
        # todo: check for need to possibly round up numbers here (1055 - 1080)
        mileageAtPreviousTurn=$distanceCovered
        
        checkIfDoctorNeeded
        printMileage
        printResourceTable
        playerMove
        foodCheck
        eat
        
        distanceCovered=$((distanceCovered +(200 + ($animalPower - 220) / 5 + ($RANDOM % 10))))
        
        isBlizzard=false
        isInsufficientClothing=false
        
        riders
        randomEvents
        mountains

        if [ $distanceCovered -ge 2040 ] || [ $turnNumber -gt 17 ]
            then finalTurn; gameOver=true
            else {
                printDate
                ((turnNumber++))                
            }
        fi
    done
}

echo -n "Do you need instructions (yes/no) "
read choice
if [ "$choice" == "yes" ]; then 
    instructions
fi

init
gameLoop
