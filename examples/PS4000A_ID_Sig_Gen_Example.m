%% PicoScope 4000 Series (A API) Instrument Driver Oscilloscope Signal Generator Example
% Code for communicating with an instrument in order to control the
% signal generator.
%
% This is a modified version of a machine generated representation of an 
% instrument control session using a device object. The instrument 
% control session comprises all the steps you are likely to take when 
% communicating with your instrument. 
% 
% These steps are:
% 
% # Create a device object   
% # Connect to the instrument 
% # Configure properties 
% # Invoke functions 
% # Disconnect from the instrument 
%  
% To run the instrument control session, type the name of the file,
% |PS4000A_ID_Sig_Gen_Example|, at the MATLAB command prompt.
% 
% The file, |PS4000A_ID_SIG_GEN_EXAMPLE.M| must be on your MATLAB PATH. For
% additional information on setting your MATLAB PATH, type |doc addpath|
% at the MATLAB command prompt.
%
% *Example:*
%   |PS4000A_ID_Sig_Gen_Example|;
%
% *Description:*
%     Demonstrates how to call Instrument Driver functions in order to control the signal
%     generator output (where available) of a PicoScope 4000 Series oscilloscope.
%
% *See also:* <matlab:doc('icdevice') icdevice> | <matlab:doc('instrument/invoke') invoke>
%
% *Copyright:* � 2014-2018 Pico Technology Limited. See |LICENSE| file for terms.

%% Test setup
% For this example the 'Gen' output of the oscilloscope was connected to
% Channel A on another PicoScope oscilloscope running the PicoScope 6
% software application. Images, where shown, depict output, or part of the
% output in the PicoScope 6 display.
%
% *Note:* The various signal generator functions called in this script may
% be combined with the functions used in the various data acquisition
% examples in order to output a signal and acquire data. The functions to
% setup the signal generator should be called prior to the start of data
% collection.

%% Load configuration information

PS4000aConfig;

%% Device connection

% Check if an Instrument session using the device object 'ps4000aDeviceObj'
% is still open, and if so, disconnect if the User chooses 'Yes' when prompted.
if (exist('ps4000aDeviceObj', 'var') && ps4000aDeviceObj.isvalid && strcmp(ps4000aDeviceObj.status, 'open'))
    
    openDevice = questionDialog(['Device object ps4000aDeviceObj has an open connection. ' ...
        'Do you wish to close the connection and continue?'], ...
        'Device Object Connection Open');
    
    if (openDevice == PicoConstants.TRUE)
        
        % Close connection to device
        disconnect(ps4000aDeviceObj);
        delete(ps4000aDeviceObj);
        
    else

        % Exit script if User 
        return;
        
    end
    
end

% Create a device object. 
% The serial number can be specified as a second input parameter.
ps4000aDeviceObj = icdevice('picotech_ps4000a_generic.mdd', '');

% Connect device object to hardware.
connect(ps4000aDeviceObj);

%% Obtain signal generator group object
% Signal Generator properties and functions are located in the Instrument
% Driver's Signalgenerator group.

sigGenGroupObj = get(ps4000aDeviceObj, 'Signalgenerator');
sigGenGroupObj = sigGenGroupObj(1);

%% Function generator - simple
% Output a Sine wave, 2000 mV p-p, 0 mV offset, 1000 Hz (uses preset values for 
% offset, peak to peak voltage and frequency)

% Wavetype : 0 (ps4000aEnuminfo.enPS4000AWaveType.PS4000A_SINE) 

[status.setSigGenBuiltInSimple] = invoke(sigGenGroupObj, 'setSigGenBuiltInSimple', 0);

%%
% 
% <<sine_wave_1kHz.PNG>>
% 

%% Function generator - sweep frequency
% Output a square wave, 2400 mV p-p, 500 mV offset, and sweep continuously from
% 500 Hz to 50 Hz in steps of 50 Hz.

% Set Signalgenerator group properties
set(ps4000aDeviceObj.Signalgenerator(1), 'startFrequency', 50.0);
set(ps4000aDeviceObj.Signalgenerator(1), 'stopFrequency', 500.0);
set(ps4000aDeviceObj.Signalgenerator(1), 'offsetVoltage', 500.0);
set(ps4000aDeviceObj.Signalgenerator(1), 'peakToPeakVoltage', 2400.0);

% Execute device object function(s).

% Wavetype       : 1 (ps4000aEnuminfo.enPS4000AWaveType.PS4000A_SQUARE) 
% Increment      : 50.0 (Hz)
% Dwell Time     : 1 (s)
% Sweep Type     : 1 (ps4000aEnuminfo.enPS4000ASweepType.PS4000A_DOWN)
% Operation      : 0 (ps4000aEnuminfo.enPS4000AExtraOperations.PS4000A_ES_OFF)
% Shots          : 0 
% Sweeps         : 0
% Trigger Type   : 0 (ps4000aEnuminfo.enPS4000ASigGenTrigType.PS4000A_SIGGEN_RISING)
% Trigger Source : 0 (ps4000aEnuminfo.enPS4000ASigGenTrigSource.PS4000A_SIGGEN_NONE)
% Ext. Threshold : 0

[status.setSigGenBuiltIn] = invoke(sigGenGroupObj, 'setSigGenBuiltIn', 1, 50.0, 1, 1, 0, 0, 0, 0, 0, 0);

%%
% 
% <<square_wave_sweep_450Hz.PNG>>
% 

%%
% 
% <<square_wave_sweep_200Hz.PNG>>
% 

%% Turn off signal generator
% Sets the output to 0 V DC.

[status.setSigGenOff] = invoke(sigGenGroupObj, 'setSigGenOff');

%%
% 
% <<sig_gen_off.PNG>>
% 

%% Arbitrary waveform generator - set parameters
% Set parameters (2000 mV p-p, 0 mV offset, 2000 Hz frequency) and define an
% arbitrary waveform.

% Set Signalgenerator group properties
set(ps4000aDeviceObj.Signalgenerator(1), 'startFrequency', 2000.0);
set(ps4000aDeviceObj.Signalgenerator(1), 'stopFrequency', 2000.0);
set(ps4000aDeviceObj.Signalgenerator(1), 'offsetVoltage', 0.0);
set(ps4000aDeviceObj.Signalgenerator(1), 'peakToPeakVoltage', 2000.0);

%%
% Define an Arbitrary Waveform - values must be in the range -1 to +1.
% Arbitrary waveforms can also be read in from text and csv files using
% |dlmread| and |csvread| respectively or use the |importAWGFile| function
% from the PicoScope Support Toolbox. 
%
% Any AWG files created using the PicoScope 6 application can be read using
% the above method.

awgBufferSize = get(sigGenGroupObj, 'awgBufferSize'); % Obtain the buffer size for the AWG
x = 0: ((2 * pi) / (awgBufferSize - 1)): 2 * pi;
y = normalise(sin(x) + sin(2 * x));

%% Arbitrary waveform generator - simple
% Output an arbitrary waveform with constant frequency (defined above).

% Arb. Waveform : y (defined above)

[status.setSigGenArbitrarySimple] = invoke(sigGenGroupObj, 'setSigGenArbitrarySimple', y);

%%
% 
% <<arbitrary_waveform.PNG>>
% 

%% Turn off signal generator
% Sets the output to 0 V DC.

[status.setSigGenOff] = invoke(sigGenGroupObj, 'setSigGenOff');

%% Arbitrary waveform generator - output shots
% Output 2 cycles of an arbitrary waveform using a software trigger.

% Increment      : 0 (Hz)
% Dwell Time     : 1 (s)
% Arb. Waveform  : y (defined above)
% Sweep Type     : 0 (ps4000aEnuminfo.enPS4000ASweepType.PS4000A_UP)
% Operation      : 0 (ps4000aEnuminfo.enPS4000AExtraOperations.PS4000A_ES_OFF)
% indexMode      : 0
% Shots          : 2 
% Sweeps         : 0
% Trigger Type   : 0 (ps4000aEnuminfo.enPS4000ASigGenTrigType.PS4000A_SIGGEN_RISING)
% Trigger Source : 4 (ps4000aEnuminfo.enPS4000ASigGenTrigSource.PS4000A_SIGGEN_SOFT_TRIG)
% Ext. Threshold : 0

[status.setSigGenArbitrary] = invoke(sigGenGroupObj, 'setSigGenArbitrary', 0, 1, y, 0, 0, 0, 2, 0, 0, 4, 0);

% Trigger the AWG

% State : 1

[status.sigGenSoftwareControl] = invoke(sigGenGroupObj, 'ps4000aSigGenSoftwareControl', 1);

%%
% 
% <<arbitrary_waveform_shots.PNG>>
% 

%% Turn off signal generator
% Sets the output to 0 V DC.

[status.setSigGenOff] = invoke(sigGenGroupObj, 'setSigGenOff');

%% Disconnect device
% Disconnect device object from hardware.

disconnect(ps4000aDeviceObj);
delete(ps4000aDeviceObj);
