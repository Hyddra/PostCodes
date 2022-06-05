#!/bin/bash

postcode=$1
url="https://api.postcodes.io/postcodes/$postcode"

function getPostCode
{
    echo -e "##### Retrieving [[ $postcode ]] details #####\n"
    sleep 2

    curl -s $url | jq '.result | .postcode, .country, .region'
}

function getValidation
{
    valid=true
    sleep 2

    if [[ $(curl -s $url/validate | jq . | grep -i "false") ]]; then
        valid=false
    fi
    if [[ $valid == true ]]; then
        echo -e "Validating postcode: [ $valid ]\n"
        getPostCode
    else
        echo -e "Validating PostCode: [ $valid ]\n"
        echo "Valid PostCode is required, Exiting..."
        exit 1
    fi
}

function getNearest
{
    echo -e "##### Retrieving [[ $postcode ]] near postcodes #####\n"
    sleep 2

    curl -s $url/nearest | jq '.result[] | .postcode, .country, .region'
}


function getJQ
{

    clear
    echo "Checking system environment..."
    
    if [[ $(cat /etc/*release | grep -i "debian") ]]; then 
        echo "Found Debian release"
        sudo apt-get -y install jq
    elif [[ $(cat /etc/*release|grep -i "redhat") ]]; then
        echo "found redhat release"
        sudo yum -y install jq
    else
        echo "Unable to identify operating system"
    fi
}

### Change me for dependencies instalation!!! ###
# getJQ

echo "---------------------------------------"
echo -e "||\tPostcode Finder"
echo -e "---------------------------------------\n"

if [[ -z $postcode ]]; then
    echo "[ERROR] - Postcode is required!"
    exit 1
else
    getValidation
fi

while true; do
    read -p "Find nearest postCodes [y/n] " ans
    case $ans in
        y) clear 
           getNearest
           exit 1 ;;
        n) echo "Exiting...."
           exit 1;;
        *) echo "Invalid response, human can't type..."
           continue ;;
    esac
done
