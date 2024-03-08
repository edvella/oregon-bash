#!/bin/bash

# Oregon Trail version based on
# PROGRAMMING REVISIONS BY DON RAWITSCH - 3/27/75
# MINNESOTA EDUCATIONAL COMPUTING CONSORTIUM STAFF

purchaseValue=-1

animalSpend=0
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
southPassFlag=false
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
        rangedPurchase "your oxen team" 200 300; animalSpend=$purchaseValue
        purchase "food"; foodLeft=$purchaseValue
        purchase "ammunition"; ammoLeft=$purchaseValue
        purchase "clothing"; clothingLeft=$purchaseValue
        purchase "miscellaneous supplies"; suppliesLeft=$purchaseValue
        
        cashLeft=$((startingBudget - animalSpend - foodLeft - ammoLeft - clothingLeft \
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
    F1=0
    F2=0
    distanceCovered=0
    southPassFlag=false
    turnNumber=0
    
    preparations
}

printDate() {
    echo
    echo "Monday ${turnDates[turnNumber]} 1847"
    echo
}

finalTurn() { 
    echo "todo"
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
    if $southPassFlag
        then echo "Total mileage is 950"; southPassFlag=false
        else echo "Total mileage is ${distanceCovered}"
    fi
}

printResourceTable() {
    #printf "Food\tBullets\tClothing\tMisc. Supp.\tCash\n"
    #("Food", "Bullets", "Clothing", "Misc. Supp.", "Cash") | xargs -n5 printf "%-15s"
    printf "%-15s%-15s%-15s%-15s%-15s\n" "Food" "Bullets" "Clothing" "Misc. Supp." "Cash"
    printf "%-15s%-15s%-15s%-15s%-15s\n" "${foodLeft}" "${ammoLeft}" "${clothingLeft}" "${suppliesLeft}" "${cashLeft}"
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

death() {
    echo
    echo "Due to your unfortunate situation, there are a few"
    echo "formalities we must go through."
    echo
    echo "Would you like a minister?"
    read
    echo "Would you like a fancy funeral?"
    read
    echo "Would you like us to inform yout next of kin?"
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
        *)
            echo "Next turn"
            ;;
    esac
}

gameLoop() {
    gameOver=false
    until $gameOver
    do
        if [ $distanceCovered -ge 2040 ] || [ $turnNumber -gt 17 ]
            then finalTurn; ganeOver=true
            else {
                # printDate
                ((turnNumber++))
                
                if [ $foodLeft -lt 0 ]; then foodLeft=0; fi
                if [ $ammoLeft -lt 0 ]; then ammoLeft=0; fi
                if [ $clothingLeft -lt 0 ]; then clothingLeft=0; fi
                if [ $suppliesLeft -lt 0 ]; then suppliesLeft=0; fi
                
                if [ $foodLeft -lt 12 ]
                    then echo "You'd better do some hunting or buy food and soon!!!!"
                fi
                
                # todo: check for need to possibly round up numbers here (1055 - 1080)
                mileageAtPreviousTurn=$distanceCovered
                
                checkIfDoctorNeeded
                printMileage
                printResourceTable
                playerMove
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
