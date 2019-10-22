%% PS4000AConfig Configure path information
% Configures paths according to platforms and loads information from
% prototype files for PicoScope 4000 Series Oscilloscopes using the
% functions from the ps4000a/libps4000a shared library. The folder that this 
% file is located in must be added to the MATLAB path.
%
% Platform Specific Information:-
%
% Microsoft Windows: Download the Software Development Kit installer from
% the <a href="matlab: web('https://www.picotech.com/downloads')">Pico Technology Download software and manuals for oscilloscopes and data loggers</a> page.
% 
% Linux: Follow the instructions to install the libps4000a and libpswrappers
% packages from the <a href="matlab:
% web('https://www.picotech.com/downloads/linux')">Pico Technology Linux Software & Drivers for Oscilloscopes and Data Loggers</a> page.
%
% Apple Mac OS X: Follow the instructions to install the PicoScope 6
% application from the <a href="matlab: web('https://www.picotech.com/downloads')">Pico Technology Download software and manuals for oscilloscopes and data loggers</a> page.
% Optionally, create a 'maci64' folder in the same directory as this file
% and copy the following files into it:
%
% * libps4000a.dylib and any other libps4000a library files
% * libps4000aWrap.dylib and any other libps4000aWrap library files
% * libpicoipp.dylib and any other libpicoipp library files
% * libiomp5.dylib 
%
% Contact our Technical Support team via the <a href="matlab: web('https://www.picotech.com/tech-support/')">Technical Enquiries form</a> for further assistance.
%
% Run this script in the MATLAB environment prior to connecting to the 
% device.
%
% This file can be edited to suit application requirements.
%
% Reference page in Help browser
%   doc PS4000aConfig

%% Set Path to Shared Libraries
% Set paths to shared library files according to the operating system and
% architecture.

% Identify working directory
ps4000aConfigInfo.workingDir = pwd;

% Find file name
ps4000aConfigInfo.configFileName = mfilename('fullpath');

% Only require the path to the config file
[ps4000aConfigInfo.pathStr] = fileparts(ps4000aConfigInfo.configFileName);

% Identify architecture e.g. 'win64'
ps4000aConfigInfo.archStr = computer('arch');
ps4000aConfigInfo.archPath = fullfile(ps4000aConfigInfo.pathStr, ps4000aConfigInfo.archStr);

% Add path to Prototype and Thunk files if not already present
if (isempty(strfind(path, ps4000aConfigInfo.archPath)))
    
    try

        addpath(ps4000aConfigInfo.archPath);
    
	catch err
    
		error('PS4000aConfig:OperatingSystemNotSupported', 'Operating system not supported - please contact support@picotech.com');
    
    end
	
end

% Set the path to drivers according to operating system.

% Define possible paths for drivers - edit to specify location of drivers

ps4000aConfigInfo.macDriverPath = '/Applications/PicoScope6.app/Contents/Resources/lib';
ps4000aConfigInfo.linuxDriverPath = '/opt/picoscope/lib/';

ps4000aConfigInfo.winSDKInstallPath = 'C:\Program Files\Pico Technology\SDK';
ps4000aConfigInfo.winDriverPath = fullfile(ps4000aConfigInfo.winSDKInstallPath, 'lib');

ps4000aConfigInfo.woW64SDKInstallPath = 'C:\Program Files (x86)\Pico Technology\SDK'; % Windows 32-bit version of MATLAB on Windows 64-bit
ps4000aConfigInfo.woW64DriverPath = fullfile(ps4000aConfigInfo.woW64SDKInstallPath, 'lib');

if (ismac())
    
    % Libraries (including wrapper libraries) are stored in the PicoScope
    % 6 App folder. Add locations of library files to environment variable
    % or place in /usr/local/lib/

    setenv('KMP_DUPLICATE_LIB_OK', 'TRUE')
    
%     setenv('DYLD_LIBRARY_PATH', '/Applications/PicoScope6.app/Contents/Resources/lib');
%     
%     if (strfind(getenv('DYLD_LIBRARY_PATH'), '/Applications/PicoScope6.app/Contents/Resources/lib'))
%        
%         % Add path to drivers if not already on the MATLAB path
%         if (isempty(strfind(path, ps4000aConfigInfo.macDriverPath)))
%         
%             addpath(ps4000aConfigInfo.macDriverPath);
%             
%         end
%         
%     else
%         
%         warning('PS4000aConfig:LibraryPathNotFound','Locations of libraries not found in DYLD_LIBRARY_PATH');
%         
%     end
    
elseif (isunix())
        
    % Add path to drivers if not already on the MATLAB path
    if (isempty(strfind(path, ps4000aConfigInfo.linuxDriverPath)))
        
        addpath(ps4000aConfigInfo.linuxDriverPath);
            
    end
        
elseif (ispc())
    
    % Microsoft Windows operating system
    
    % Set path to dll files if the Pico Technology SDK Installer has been
    % used or place dll files in the same folder. Detect if 32-bit version
    % of MATLAB on 64-bit Microsoft Windows.
    if (strcmp(ps4000aConfigInfo.archStr, 'win32') && exist('C:\Program Files (x86)\', 'dir') == 7)
       
        % Add path to drivers if not already on the MATLAB path
        if (isempty(strfind(path, ps4000aConfigInfo.woW64DriverPath)))
        
            try
                
                addpath(ps4000aConfigInfo.woW64DriverPath);
                
			catch err
           
				warning('PS4000aConfig:DirectoryNotFound', ['Folder C:\Program Files (x86)\Pico Technology\SDK\lib\ not found. '...
					'Please ensure that the location of the library files are on the MATLAB path.']);
            
            end
			
        end
        
    else
        
        % 32-bit MATLAB on 32-bit Windows or 64-bit MATLAB on 64-bit
        % Windows operating systems
        
		% Add path to drivers if not already on the MATLAB path
        if (isempty(strfind(path, ps4000aConfigInfo.winDriverPath)))
            
            try 

                addpath(ps4000aConfigInfo.winDriverPath);
            
			catch err
           
				warning('PS4000aConfig:DirectoryNotFound', ['Folder C:\Program Files\Pico Technology\SDK\lib\ not found. '...
					'Please ensure that the location of the library files are on the MATLAB path.']);
            
            end
			
        end
        
    end
    
else
    
    error('PS4000aConfig:OperatingSystemNotSupported', 'Operating system not supported - please contact support@picotech.com');
    
end

%% Set path for PicoScope Support Toolbox files if not installed
% Set MATLAB Path to include location of PicoScope Support Toolbox
% Functions and Classes if the Toolbox has not been installed. Installation
% of the toolbox is only supported in MATLAB 2014b and later versions.

% Check if PicoScope Support Toolbox is installed - using code based on
% <http://stackoverflow.com/questions/6926021/how-to-check-if-matlab-toolbox-installed-in-matlab How to check if matlab toolbox installed in matlab>

ps5000aConfigInfo.psTbxName = 'PicoScope Support Toolbox';
ps5000aConfigInfo.v = ver; % Find installed toolbox information

if (~any(strcmp(ps5000aConfigInfo.psTbxName, {ps5000aConfigInfo.v.Name})))
   
    warning('PS5000aConfig:PSTbxNotFound', 'PicoScope Support Toolbox not found, searching for folder.');
    
    % If the PicoScope Support Toolbox has not been installed, check to see
    % if the folder is on the MATLAB path, having been downloaded via zip
    % file.
    
    ps5000aConfigInfo.psTbxFound = strfind(path, ps5000aConfigInfo.psTbxName);
    
    if (isempty(ps5000aConfigInfo.psTbxFound))
        
        ps5000aConfigInfo.psTbxNotFoundWarningMsg = sprintf(['Please either:\n'...
            '(1) install the PicoScope Support Toolbox via the Add-Ons Explorer or\n'...
            '(2) download the zip file from MATLAB Central File Exchange and add the location of the extracted contents to the MATLAB path.']);
        
        warning('PS5000aConfig:PSTbxDirNotFound', ['PicoScope Support Toolbox not found. ', ps5000aConfigInfo.psTbxNotFoundWarningMsg]);
        
        ps5000aConfigInfo.f = warndlg(ps5000aConfigInfo.psTbxNotFoundWarningMsg, 'PicoScope Support Toolbox Not Found', 'modal');
        uiwait(ps5000aConfigInfo.f);
        
        web('https://uk.mathworks.com/matlabcentral/fileexchange/53681-picoscope-support-toolbox');
            
    end
    
end

% Change back to the folder where the script was called from.
cd(ps4000aConfigInfo.workingDir);

%% Load Enumerations and Structure Information
% Enumerations and structures are used by certain Intrument Driver functions.

% Find prototype file names based on architecture

ps4000aConfigInfo.ps4000aMFile = str2func(strcat('ps4000aMFile_', ps4000aConfigInfo.archStr));

[ps4000aMethodinfo, ps4000aStructs, ps4000aEnuminfo, ps4000aThunkLibName] = ps4000aConfigInfo.ps4000aMFile(); 

