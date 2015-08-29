asterisk-dongle
===============

**only for test! not working now!**

"asterisk-dongle" docker image is a vanilla Asterisk Certified PBX compilation on GNU/Linux Debian 8 and chan_dongle module for Asterisk 13.
This is "fork" of: https://hub.docker.com/r/linuxconfig/asterisk/
This Docker container:

 - Debian 8
 - Asterisk 13.1 Certified PBX compilation (https://hub.docker.com/r/linuxconfig/asterisk/)
 - chan_dongle module for Asterisk 13 (https://github.com/oleg-krv/asterisk-chan-dongle )
 - Russian voice for Asterisk (https://github.com/pbxware/asterisk-sounds)


----------

**dongle.conf**

    [general]
    interval=15			; Number of seconds between trying to connect to devices
    ;------------------------------ JITTER BUFFER CONFIGURATION --------------------------
    ;jbenable = yes			; Enables the use of a jitterbuffer on the receiving side of a
    				; Dongle channel. Defaults to "no". An enabled jitterbuffer will
    				; be used only if the sending side can create and the receiving
    				; side can not accept jitter. The Dongle channel can't accept jitter,
    				; thus an enabled jitterbuffer on the receive Dongle side will always
    				; be used if the sending side can create jitter.
    ;jbforce = no			; Forces the use of a jitterbuffer on the receive side of a Dongle
    				; channel. Defaults to "no".
    ;jbmaxsize = 200		; Max length of the jitterbuffer in milliseconds.
    ;jbresyncthreshold = 1000	; Jump in the frame timestamps over which the jitterbuffer is
    				; resynchronized. Useful to improve the quality of the voice, with
    				; big jumps in/broken timestamps, usually sent from exotic devices
    				; and programs. Defaults to 1000.
    ;jbimpl = fixed			; Jitterbuffer implementation, used on the receiving side of a Dongle
    				; channel. Two implementations are currently available - "fixed"
    				; (with size always equals to jbmaxsize) and "adaptive" (with
    				; variable size, actually the new jb of IAX2). Defaults to fixed.
    ;jbtargetextra = 40		; This option only affects the jb when 'jbimpl = adaptive' is set.
    				; The option represents the number of milliseconds by which the new jitter buffer
    				; will pad its size. the default is 40, so without modification, the new
    				; jitter buffer will set its size to the jitter value plus 40 milliseconds.
    				; increasing this value may help if your network normally has low jitter,
    				; but occasionally has spikes.
    ;jblog = no			; Enables jitterbuffer frame logging. Defaults to "no".
    ;-----------------------------------------------------------------------------------
    [defaults]
    ; now you can set here any not required device settings as template
    ;   sure you can overwrite in any [device] section this default values
    context=default			; context for incoming calls
    group=0				; calling group
    rxgain=+3			; increase the incoming volume; may be negative
    txgain=-3			; increase the outgoint volume; may be negative
    autodeletesms=yes		; auto delete incoming sms
    resetdongle=yes			; reset dongle during initialization with ATZ command
    u2diag=-1			; set ^U2DIAG parameter on device (0 = disable everything except modem function) ; -1 not use ^U2DIAG command
    usecallingpres=yes		; use the caller ID presentation or not
    callingpres=allowed_passed_screen ; set caller ID presentation		by default use default network settings
    disablesms=no			; disable of SMS reading from device when received
    				;  chan_dongle has currently a bug with SMS reception. When a SMS gets in during a
    				;  call chan_dongle might crash. Enable this option to disable sms reception.
    				;  default = no
    language=ru`enter code here`			; set channel default language
    smsaspdu=yes			; if 'yes' send SMS in PDU mode, feature implementation incomplete and we strongly recommend say 'yes'
    mindtmfgap=45			; minimal interval from end of previews DTMF from begining of next in ms
    mindtmfduration=80		; minimal DTMF tone duration in ms
    mindtmfinterval=200		; minimal interval between ends of DTMF of same digits in ms
        callwaiting=auto		; if 'yes' allow incoming calls waiting; by default use network settings
    				; if 'no' waiting calls just ignored
    disable=no			; OBSOLETED by initstate: if 'yes' no load this device and just ignore this section
    initstate=start			; specified initial state of device, must be one of 'stop' 'start' 'remote'
    				;   'remove' same as 'disable=yes'
    exten=+1234567890		; exten for start incoming calls, only in case of Subscriber Number not available!, also set to CALLERID(ndid)
    dtmf=relax			; control of incoming DTMF detection, possible values:
    				;   off	   - off DTMF tones detection, voice data passed to asterisk unaltered
    				;              use this value for gateways or if not use DTMF for AVR or inside dialplan
    				;   inband - do DTMF tones detection
    				;   relax  - like inband but with relaxdtmf option
    				;  default is 'relax' by compatibility reason
    ; dongle required settings
    [dongle0]
    audio=/dev/ttyUSB1		; tty port for audio connection; 	no default value
    data=/dev/ttyUSB2		; tty port for AT commands; 		no default value
    ; or you can omit both audio and data together and use imei=123456789012345 and/or imsi=123456789012345
    ;  imei and imsi must contain exactly 15 digits !
    ;  imei/imsi discovery is available on Linux only
    imei=123456789012345
    imsi=123456789012345
    ; if audio and data set together with imei and/or imsi audio and data has precedence
    ;   you can use both imei and imsi together in this case exact match by imei and imsi required

**extensions.conf**

    ; this is chunks of Asterisk extensions.conf file for show some chan_dongle features
    [general]
    [dongle-incoming]
    ; example of ussd receive
    exten => ussd,1,Set(type=${USSD_TYPE})
    	; values from 0 till 5
    	;  0 - 'USSD Notify'
    	;  1 - 'USSD Request'
    	;  2 - 'USSD Terminated by network'
    	;  3 - 'Other local client has responded'
    	;  4 - 'Operation not supported'
    	;  5 - 'Network time out'
    exten => ussd,n,Set(typestr=${USSD_TYPE_STR})
    	; type in string, see above
    exten => ussd,n,Set(ussd=${USSD})
    	; USSD text, but may be truncated by first \n
    exten => ussd,n,Set(ussd_multiline=${BASE64_DECODE(${USSD_BASE64})})
    	; USSD text, may be multiline
    ; Note:  this exten run in Local channel not attached to anything, also all CALLERID() is empty
    exten => ussd,n,Hangup
    ; example of sms receive
    exten => sms,1,Set(sms=${SMS})
    	; SMS text, but may be truncated by first \n
    exten => sms,n,Set(sms_multiline=${BASE64_DECODE(${SMS_BASE64})})
    	; SMS text, may be multiline
    exten => sms,n,Set(raw_cmgr_message=${CMGR})
    	; raw CMGR message from dongle
    ; Note:  this exten run in Local channel not attached to anything, also CALLERID(num) is address of SMS originator
    exten => sms,n,Hangup
    ; example of begining context execution from not default exten
    exten => +12345678901,1,Verbose(This exten executed if Subscriber Number is available and equal +12345678901 or exten setting value is +12345678901)
    exten => +12345678901,n,Hangup
    ; example of channel variables setting by chan_dongle
    exten => s,1,Set(NAME_OF_DEVICE=${DONGLE0_STATUS})
        ; for example 'dongle0' or 'dongle1' see dongle.conf
    exten => s,n,Set(NAME_OF_PROVIDE=${DONGLEPROVIDER})
        ; for example see output of cli 'dongle show devices' column "Provider Name"
    exten => s,n,Set(IMEI_OF_DEVICE=${DONGLEIMEI})
        ; for example see output of cli 'dongle show devices' column "IMEI"
    exten => s,n,Set(IMSI_OF_SIMCARD=${DONGLEIMSI})
        ; for example see output of cli 'dongle show devices' column "IMSI"
    exten => s,n,Set(SUBSCRIBER_NUMBER=${DONGLENUMBER})
        ; Subscriber Number example see output of cli 'dongle show devices' column "Number"
        ;   may be empty, use for save in SIM commands AT+CPBS="ON" and  AT+CPBW=1,"+123456789",145
    exten => s,n,Set(CNUM_NUMBER=${CALLERID(dnid)})
        ; Set to Subscriber Number if available
    ; applications of chan_dongle
    exten => s,n,DongleStatus(dongle0,DONGLE0_STATUS)
    exten => s,n,DongleStatus(g1,DONGLE1_STATUS)
    exten => s,n,DongleStatus(r1,DONGLE2_STATUS)
    exten => s,n,DongleStatus(p:PROVIDER NAME,DONGLE3_STATUS)
    exten => s,n,DongleStatus(i:123456789012345,DONGLE4_STATUS)
    exten => s,n,DongleStatus(s:25099,DONGLE5_STATUS)
        ; for first argument see Dial() Resource part of dial string
        ; get status of device and store result in variable
        ; possible values of ${DONGLE0_STATUS}
        ;	-1 invalid argument
        ;	 1 device not found
        ;	 2 device connected and free
        ;    3 device connected and in use
    exten => s,n,DongleSendSMS(dongle0,+18004005422,"Hello how are you, Danila?",1440,yes)
        ; send SMS on selected device and to specified number
        ;   device			name of Dongle device
        ;   destination number	in International format with leading '+' or w/o leading '+'
        ;   message			maximum 70 UCS-2 symbols
        ;   validity period 	in minutes, will be round up to nearest possible value, optional default is 3 days
        ;   report request		if true report for this SMS is required, optional default is not
    ; functions of chan_dongle
    exten => s,n,GotoIf($["${CHANNEL(callstate)}" = "waiting"]?waiting-call)
        ; now we provide channel function argument callstate
        ;	possible values
        ;		active		; enjoy and speek
        ;		held		; this call is held
        ;		dialing		; for outgoing calls
        ;		alerting	; for outgoing calls, number dialed and called party ringing
        ;		incoming	; for incoming calls
        ;		waiting		; for incoming waiting calls;
        ;                              if callwaiting=no channels for waiting calls never created
        ;		initialize	; never appear
        ;		released	; never appear
       ; Answer on waiting call activate this call and place any other active calls 
        ;   on hold, but execution of dialplan for these calls not break stopped or frozen
        ;   When active call terminated one of held becomes active.
    exten => s,n,Set(CHANNEL(callstate)=active)
        ; if callstate is 'held' you can assign new value 'active'
        ;   its mean activate this call and place on hold all other active calls but 
        ;   execution of dialplan for these calls not break stopped or frozen
    exten => s,n,GotoIf($["${CHANNEL(dtmf)}" != "off"]?turn_off_dtmf)
        ; you can read actual value of DTMF detection settings
        ;	possible values
        ;		off		; DTMF detection is off
        ;		inband		; detect DTMF inband
        ;		relax		; detect DTMF inband with relax option as defined in main asterisk docs
    exten => s,n,Set(CHANNEL(dtmf)=off)
        ; example usage of assign to channel local DTMF settings
        ;   this not overwrite global config file settings and apply only for this channel
    exten => s,n,Dial(Dongle/dongle0/+79139131234)
    exten => s,n,Dial(Dongle/g1/+79139131234)
    exten => s,n,Dial(Dongle/r1/879139131234)
    exten => s,n,Dial(Dongle/p:PROVIDER NAME/+79139131234)
    exten => s,n,Dial(Dongle/i:123456789012345/+79139131234)
    exten => s,n,Dial(Dongle/s:25099/+79139131234)
        ; make outgoing call
        ;  name on device with this name
        ;  g1 on first free device in group 1
        ;  r1 round robin devices in group 1
        ;  p: with first free device with Operator name beggining with name
        ;  i: with device exactly matched IMEI
        ;  s: with first free device with IMSI prefix
    exten => s,n,Dial(Dongle/g1/holdother:+79139131234)
    exten => s,n,Dial(Dongle/r1/holdother:+79139131234)
    exten => s,n,Dial(Dongle/p:PROVIDER NAME/holdother:+79139131234)
    exten => s,n,Dial(Dongle/i:123456789012345/holdother:+79139131234)
    exten => s,n,Dial(Dongle/s:25099/holdother:+79139131234)
        ; now we add option 'holdother' for dialing
        ;	 this option do
        ;		1) When looking for available devices by group, provider IMEI, 
        ;			IMSI prefix not ignore devices with whose state does not 
        ;                   prohibit a new outgoing call when other call place on hold
        ;
        ;		2) Before actual dialing place active calls on hold
        ;                  but execution of dialplan for these calls not break stopped or frozen
        ;		3) This call will be active if succesfully answered
    ; BUG !!!
    ;  tested for call waiting and hold features Huawei E1550 has a next bug:
    ;    When local side hangup any call including held call ALL other calls LOST sound
    ;    When remove side hangup active call ALL other calls LOST sound
    ; Please double check true this for you or not
    ;  If true reduce usage of this useful features
    exten => s,n,Dial(Dongle/g1/conference:+79139131234)
    exten => s,n,Dial(Dongle/r1/conference:+79139131234)
    exten => s,n,Dial(Dongle/p:PROVIDER NAME/conference:+79139131234)
    exten => s,n,Dial(Dongle/i:123456789012345/conference:+79139131234)
    exten => s,n,Dial(Dongle/s:25099/conference:+79139131234)
        ; and also option 'conference' added
        ;	 this option do
        ;		1) When looking for available devices by group, provider IMEI, 
        ;			IMSI prefix not ignore devices with whose state does not 
        ;                   prohibit a new outgoing call when other call place on hold
        ;
        ;		2) Before actual dialing place active calls on hold
        ;                  but execution of dialplan for these calls not break stopped or frozen
        ;		3) If answered attach hold calls to conrefence (in term of GSM)
        ; Also if created outgoing channel place call on same device that incoming channel
        ;  both incoming and outgoing channels become readonly to avoid the voice loop.
        ;
        ; see also BUG !!! note above
    exten => s,n,Hangup
