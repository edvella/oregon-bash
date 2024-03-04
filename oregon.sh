#!/bin/bash

# Oregon Trail version based on
# PROGRAMMING REVISIONS BY DON RAWITSCH - 3/27/75
# MINNESOTA EDUCATIONAL COMPUTING CONSORTIUM STAFF

purchaseValue=-1

AnimalSpend=0
AmmoSpend=0
ClothingSpend=0
FoodSpend=0
MiscSuppliesSpend=0

startingBudget=700
cashLeft=$startingBudget
distanceCovered=0
turnNumber=0

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
        rangedPurchase "your oxen team" 200 300; AnimalSpend=$purchaseValue
        purchase "food"; FoodSpend=$purchaseValue
        purchase "ammunition"; AmmoSpend=$purchaseValue
        purchase "clothing"; ClothingSpend=$purchaseValue
        purchase "miscellaneous supplies"; MiscSuppliesSpend=$purchaseValue
        
        cashLeft=$((startingBudget - AnimalSpend - FoodSpend - AmmoSpend - ClothingSpend \
                - MiscSuppliesSpend))
            
        if [ $cashLeft -lt 0 ]
          then echo "You overspent--you only had \$$startingBudget to spend. Buy again."
          else preparationsComplete=true
        fi
        
    done
    
    ammoSpend=$((50 * AmmonSpend))
    echo "After all your purchases, you now have $cashLeft dollars left."
    echo
    echo "Monday, March 29, 1847"
    echo
}

init() {
    X1=-1
    K8=0
    S4=0
    F1=0
    F2=0
    distanceCovered=0
    M9=0
    D3=0
    
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

gameLoop() {
    if [ $distanceCovered -ge 2040 ] || [ $turnNumber -gt 17 ]
        then finalTurn
        else printDate
    fi
}

echo -n "Do you need instructions (yes/no) "
read choice
if [ "$choice" == "yes" ]; then 
    instructions
fi

init
gameLoop
