#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Galactic Salon Services ~~~~~\n"

MAIN_MENU()
{
  if [[ $1 ]] 
   then
    echo -e "\n$1"
  fi

  #get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # display available services
  echo -e "\nHere are the available services, just pick one:"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  
# if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
     then 
     # send to main menu
        MAIN_MENU "That is not a valid number."
      else
        #check if such a service exists
        B_SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        #if not
        if [[ -z $B_SERVICE_EXISTS ]]
         then
          #send to main menu
          MAIN_MENU "Such a service doesn't exist yet."
         else
          ACTIVATE_SERVICE $SERVICE_ID_SELECTED
        fi
    fi
}

ACTIVATE_SERVICE()
{
  if [[ $1 ]] 
    then
      #get service name
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1")
      echo -e "\nSERVICE ACTIVATION: $SERVICE_NAME"

      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      #check if such a cusomter exists
      RESULT_CUSTOMER_TEST=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      #if not
      if [[ -z $RESULT_CUSTOMER_TEST ]]
        then
          echo -e "\nHey, what's your name?"
          read CUSTOMER_NAME

          # insert new customer
            RESULT_INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers ORDER BY customer_id DESC LIMIT 1")
        else
            CUSTOMER_ID=$RESULT_CUSTOMER_TEST
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
      fi

      echo -e "\nUmm, what hour would be ok?"
      read SERVICE_TIME

      # insert new appointment
        RESULT_INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $1, '$SERVICE_TIME')")

      # THANK YOU
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      
    fi 
}

MAIN_MENU