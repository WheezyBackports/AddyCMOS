#!/bin/sh

SRVPATH=/srv/xmrig-mo
CONFPATH=$SRVPATH/conf.d

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            WALLETADDR)              WALLETADDR=${VALUE} ;;
            WORKERNAME)    	     WORKERNAME=${VALUE} ;;     
	    POOLADDR)		     POOLADDR=${VALUE}	 ;;
	    NOFEE)		     NOFEE=${VALUE}	 ;;
	    LOG)		     LOG=${VALUE}	 ;;
            *)   
    esac    


done


cp $CONFPATH/template-config.json $CONFPATH/config.json && echo "Copied new config file from template."

if test "$WALLETADDR" != ''; then 
	echo "Using wallet address : $WALLETADDR";
	sed -i "s/YOUR_WALLET_ADDRESS/$WALLETADDR/g" $CONFPATH/config.json && echo "Wrote wallet address to config.";
	SETUPINIT=yes
else
	echo "You need to specify a wallet address!"
fi

if test "$WORKERNAME" != ''; then 
	echo "Using worker name :  $WORKERNAME";
	sed -i "s/\"x/\"$WORKERNAME/g" $CONFPATH/config.json && echo "Wrote worker name to config."
else
	echo "You need to specify a worker name!"
fi

if test "$POOLADDR" != ''; then
	sed -i "s/gulf.moneroocean.stream:10128/$POOLADDR/g" $CONFPATH/config.json && echo "Changed pool address to : $POOLADDR"
fi

if test "$NOFEE" = 'y'; then 
	sed -i "s/%0.1%42dAoQQFiT31Z86XPhrj7Y1nKwW8jvMDpTPZZTV1SfgS7vvBt24xgRneuQ3gmCuhQVUmKtMnVNEnQ8K589g2eFtTEam8HqU//g" $CONFPATH/config.json && echo "Removed AddyCMOS dev fee." 
fi

if test "$LOG" = 'y'; then
	LOGPATH=$SRVPATH/log.txt;
	sed -i "s+\"log-file\"\: null,+\"log-file\"\: \"$LOGPATH\",+g" $CONFPATH/config.json
fi

if test "$SETUPINIT" = 'yes'; then 
	echo "Setting up init script.";
	doas rc-update add xmrigboot default;
	doas rc-service xmrigboot start;
	doas rc-service xmrigboot stop 
else
	echo "Setup init failed!"
fi


