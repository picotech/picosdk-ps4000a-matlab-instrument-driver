%% PicoScope 4000 Series (A API) Instrument Driver Oscilloscope Rapid Block Data Capture Example
% This is an example of an instrument control session using a device 
% object. The instrument control session comprises all the steps you 
% are likely to take when communicating with your instrument. 
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
% PS4000A_ID_Rapid_Block_Plot3D_Example, at the MATLAB command prompt.
% 
% The file, PS4000A_ID_RAPID_BLOCK_PLOT3D.M must be on your MATLAB PATH.
% For additional information on setting your MATLAB PATH, type 'help
% addpath' at the MATLAB command prompt.
%
% *Example:*
%     PS4000A_ID_Rapid_Block_Plot3D_Example;
%   
% *Description:*
%     Demonstrates how to call functions in order to capture data in rapid block
%     mode from a PicoScope 4000 Series Oscilloscope using the underlying
%     'A' API.
%   
% *See also:* <matlab:doc('icdevice') icdevice> | <matlab:doc('instrument/invoke') invoke>
%
% *Copyright:* (C) Pico Technology Limited 2014 - 2015. All rights reserved.

%% Suggested Input Test Signal
% This example was published using the following test signal:
%
% * Channel A: Swept sine wave (Start: 50Hz, Stop: 1kHz, Sweep type: Up, Increment: 40Hz, Increment Time: 10ms)

%% Clear Command Window

clc;

%% Load Configuration Information
PS4000aConfig;

%% Device Connection

% Create a device object. 
% The serial number can be specified as a second input parameter.
ps4000aDeviceObj = icdevice('picotech_ps4000a_generic.mdd', '');

% Connect device object to hardware.
connect(ps4000aDeviceObj);

%% Set Channels

% Default driver settings applied to channels are listed below - 
% use ps4000aSetChannel to turn channels on or off and set voltage ranges, 
% coupling, as well as analogue offset.

% In this example, data is only collected on Channel A so default settings
% are used and channels B to H are switched off.

% Channels       : 1 - 7 (ps4000aEnuminfo.enPS4000AChannel.PS4000A_CHANNEL_B - PS4000A_CHANNEL_H)
% Enabled        : 0
% Type           : 1 (ps4000aEnuminfo.enPS4000ACoupling.PS4000A_DC)
% Range          : 8 (ps4000aEnuminfo.enPS4000ARange.PS4000A_5V)
% Analogue Offset: 0.0

% Execute device object function(s).
[status.setChB] = invoke(ps4000aDeviceObj, 'ps4000aSetChannel', 1, 0, 1, 8, 0.0);

if(ps4000aDeviceObj.channelCount == PicoConstants.QUAD_SCOPE || ...
        ps4000aDeviceObj.channelCount == PicoConstants.OCTO_SCOPE)
    
    [status.setChC] = invoke(ps4000aDeviceObj, 'ps4000aSetChannel', 2, 0, 1, 8, 0.0);
    [status.setChD] = invoke(ps4000aDeviceObj, 'ps4000aSetChannel', 3, 0, 1, 8, 0.0);
    
end

if(ps4000aDeviceObj.channelCount == PicoConstants.OCTO_SCOPE)
    
    [status.setChE] = invoke(ps4000aDeviceObj, 'ps4000aSetChannel', 4, 0, 1, 8, 0.0);
    [status.setChF] = invoke(ps4000aDeviceObj, 'ps4000aSetChannel', 5, 0, 1, 8, 0.0);
    [status.setChG] = invoke(ps4000aDeviceObj, 'ps4000aSetChannel', 6, 0, 1, 8, 0.0);
    [status.setChH] = invoke(ps4000aDeviceObj, 'ps4000aSetChannel', 7, 0, 1, 8, 0.0);

end

%% Set Memory Segments
% Configure number of memory segments and query ps4000aGetMaxSegments to
% find the maximum number of samples for each segment.

% nSegments : 128

[status.memorySegments, nMaxSamples] = invoke(ps4000aDeviceObj, 'ps4000aMemorySegments', 128);

%% Verify Timebase Index and Maximum Number of Samples
% Driver default timebase index used - use ps4000aGetTimebase2 to query the
% driver as to suitability of using a particular timebase index and the
% maximum number of samples available in the segment selected then set the
% 'timebase' property if required.
%
% To use the fastest sampling interval possible, set one analogue channel
% and turn off all other channels.
%
% Use a while loop to query the function until the status indicates that a
% valid timebase index has been selected. In this example, the timebase 
% index of 49 is valid. 

% Initial call to ps4000aGetTimebase2 with parameters:
% timebase      : 49
% segment index : 0

status.getTimebase2 = PicoStatus.PICO_INVALID_TIMEBASE;
timebaseIndex = 49;

while(status.getTimebase2 == PicoStatus.PICO_INVALID_TIMEBASE)

    [status.getTimebase2, timeIntervalNanoSeconds, maxSamples] = invoke(ps4000aDeviceObj, 'ps4000aGetTimebase2', timebaseIndex, 0);
    
    if(status.getTimebase2 == PicoStatus.PICO_OK)
       
        break;
        
    else
        
        timebaseIndex = timebaseIndex + 1;
        
    end

end

set(ps4000aDeviceObj, 'timebase', timebaseIndex);

%% Set Simple Trigger 
% Set a trigger on Channel A, with an auto timeout - the default value for
% delay is used. The trigger will wait for a rising edge through the specified
% threshold unless the timeout occurs first.

% Trigger properties and functions are located in the Instrument
% Driver's Trigger group.

triggerGroupObj = get(ps4000aDeviceObj, 'Trigger');
triggerGroupObj = triggerGroupObj(1);

% Set the autoTriggerMs property in order to automatically trigger the
% oscilloscope after 2 seconds if a trigger event has not occurred. Set to 
% 0 to wait indefinitely for a trigger event.

set(triggerGroupObj, 'autoTriggerMs', 2000);

% Channel     : 0 (ps4000aEnuminfo.enPS4000AChannel.PS4000A_CHANNEL_A)
% Threshold   : 500 (mV)
% Direction   : 2 (ps4000aEnuminfo.enPS4000AThresholdDirection.PS4000A_RISING)

[status.setSimpleTrigger] = invoke(triggerGroupObj, 'setSimpleTrigger', 0, 500, 2);

%% Setup Rapid Block Parameters and Capture Data
% Capture a set of rapid block data and retrieve data values for Channel A.

% Rapid Block specific properties and functions are located in the Instrument
% Driver's Rapidblock group.

rapidBlockGroupObj = get(ps4000aDeviceObj, 'Rapidblock');
rapidBlockGroupObj = rapidBlockGroupObj(1);

% Set the number of waveforms to captures

% nCaptures : 16

numCaptures = 16;
[status.setNoOfCaptures] = invoke(rapidBlockGroupObj, 'ps4000aSetNoOfCaptures', numCaptures);

% Set the number of pre- and post-trigger samples to collect. Ensure that
% the total does not exceeed nMaxSamples above.

set(ps4000aDeviceObj, 'numPreTriggerSamples', 2500);
set(ps4000aDeviceObj, 'numPostTriggerSamples', 7500);

% Block specific properties and functions are located in the Instrument
% Driver's Block group.

blockGroupObj = get(ps4000aDeviceObj, 'Block');
blockGroupObj = blockGroupObj(1);

%%
% This example uses the _runBlock_ function in order to collect a block of
% data - if other code needs to be executed while waiting for the device to
% indicate that it is ready, use the _ps4000aRunBlock_ function and poll
% the _ps4000aIsReady_ function.

% Capture the blocks of data

% segmentIndex : 0 

[status.runBlock, timeIndisposedMs] = invoke(blockGroupObj, 'runBlock', 0);

% Retrieve Rapid Block Data

% numCaptures : 16
% ratio       : 1
% ratioMode   : 0 (ps4000aEnuminfo.enPS4000ARatioMode.PS4000A_RATIO_MODE_NONE)

% Provide additional output arguments for the remaining channels e.g. chB
% for Channel B
[numSamples, overflow, chA] = invoke(rapidBlockGroupObj, 'getRapidBlockData', 16, 1, 0);

% Stop the Device
[status.stop] = invoke(ps4000aDeviceObj, 'ps4000aStop');

%% Process data
% Plot data values in 3D showing history.

figure1 = figure('Name','PicoScope 4000 Series Example - Rapid Block Mode Capture', ...
    'NumberTitle', 'off');

% Calculate time period over which samples were taken for each waveform. 
% Use the timeIntervalNanoSeconds output from the ps4000aGetTimebase2
% function or calculate it using the main Programmer's Guide.

timeNs = double(timeIntervalNanoSeconds) * double(0:numSamples - 1);

% Channel A
axes1 = axes('Parent', figure1);
view(axes1,[-15 24]);
grid(axes1,'on');
hold(axes1,'all');

for i = 1:numCaptures
    
    plot3(timeNs, i * (ones(numSamples, 1)), chA(:, i));
    
end

title('Rapid Block Data Acquisition - Channel A');
xlabel('Time (ns)');
ylabel('Capture');
zlabel('Voltage (mV)');

hold off;

%% Disconnect Device
% Disconnect device object from hardware.

disconnect(ps4000aDeviceObj);
delete(ps4000aDeviceObj);