%% PS4000aConstants Defines PicoScope 4000 Series constants from header file ps4000AApi.h
%
% The PS4000aConstants class defines a number of constant values that can
% be used to define the properties of a PicoScope 4000 Series
% Oscilloscope (using the 'A' API) or for passing as parameters to
% function calls.
%
% The properties in this file are divided into the following
% sub-sections:
% 
% * ADC Count Properties
% * External trigger: Max/min counts
% * Trigger Properties
% * Analogue offset values
% * Function/Arbitrary Waveform Parameters
% * Maximum/Minimum Waveform Frequencies
% * PicoScope 4000 Series Models (using the 'A' API)
%
% Ensure that this class file is on the MATLAB Path.		
%
% Copyright: © Pico Technology Limited 2014 - 2017. See LICENSE file for terms.	

classdef PS4000aConstants
    
    properties (Constant)
        
        % ADC Count Properties
        
        PS4000A_MAX_VALUE               = 32767;    % ADC Counts
		PS4000A_MIN_VALUE               = -32767;   % ADC Counts
		
        % External trigger: Max/min counts
        
        PS4000A_EXT_MAX_VALUE           = 32767;    % Counts
		PS4000A_EXT_MIN_VALUE           = -32767;   % Counts

        % Trigger Properties
        
        MAX_PULSE_WIDTH_QUALIFIER_COUNT = 16777215;
		MAX_DELAY_COUNT 				= 8388607;
        
        % Analogue offset values (Volts)
        
        PS4000A_MAX_ANALOGUE_OFFSET_50MV_200MV  = 0.250;
        PS4000A_MIN_ANALOGUE_OFFSET_50MV_200MV  = -0.250;
        PS4000A_MAX_ANALOGUE_OFFSET_500MV_2V    = 2.500;
        PS4000A_MIN_ANALOGUE_OFFSET_500MV_2V    = -2.500;
        PS4000A_MAX_ANALOGUE_OFFSET_5V_20V      = 20;
        PS4000A_MIN_ANALOGUE_OFFSET_5V_20V      = -20;
        
        % Function/Arbitrary Waveform Parameters

		PS4000A_MAX_SIG_GEN_BUFFER_SIZE = 16384;   
        PS4000A_MIN_SIG_GEN_BUFFER_SIZE = 10;
        PS4000A_MIN_DWELL_COUNT         = 10;
        PS4000A_MAX_SWEEPS_SHOTS		= pow2(30) - 1; % 1073741823

        % Maximum/Minimum Waveform Frequencies (in Hertz)
        
        PS4000A_SINE_MAX_FREQUENCY      = 1000000;
        PS4000A_SQUARE_MAX_FREQUENCY    = 1000000;
        PS4000A_TRIANGLE_MAX_FREQUENCY	= 1000000;
        PS4000A_SINC_MAX_FREQUENCY		= 1000000
        PS4000A_RAMP_MAX_FREQUENCY		= 1000000;
        PS4000A_HALF_SINE_MAX_FREQUENCY	= 1000000;
        PS4000A_GAUSSIAN_MAX_FREQUENCY  = 1000000;
        PS4000A_MIN_FREQUENCY           = 0.03;

        % PicoScope 4000 Series Models (using the ps4000a driver)
        
        MODEL_NONE      = 'NONE';
        
        % Variants that can be used
        MODEL_PS4225   = '4225';
        MODEL_PS4425   = '4425';
        MODEL_PS4444   = '4444';
		MODEL_PS4824   = '4824';

    end

end

