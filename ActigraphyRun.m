function ActigraphyRun(FoundVideoFilesPath,BBParentPath,GeneralOutputsPath,BBlist,BBToAnalyze)
% FoundVideoFilesPath = 'C:\Users\duck7\Documents\lab shit';
% BBParentPath = 'C:\Users\duck7\Documents\lab shit';
% GeneralOutputsPath = 'C:\Users\duck7\Documents\lab shit\GeneralOutputs';
FoundVideoFilesPath = 'C:\Users\duck7\Documents\BB16 ActigraphyResults-20220126T164933Z-001';
BBParentPath = 'C:\Users\duck7\Documents\BB16 ActigraphyResults-20220126T164933Z-001';
GeneralOutputsPath = 'C:\Users\duck7\Documents\BB16 ActigraphyResults-20220126T164933Z-001';
BBlist = {'16'};
BBToAnalyze = [true];

%Notes on naming: Alright. Much like a lot of matlab functions that accept
%inputs as files from your computer, the names of the files that you put in
%have to be pretty specific. Each of the BB videos need to look like this: 
%BehavioralBox_B17_T20210713-1800000000
%If it does not look EXACTLY like this, then this entire thing will break
%and set fire to your computer, the lab, and consequently, your career.
%PLEASE make sure that this is correct. I'll probably make a small function
%that will go in and change the names of the files to be like this. 

%OH This is important... You need to include the folder PhoWatsonCommon
%from the Watson lab master code branch. If you get the error that you
%don't have the function FnSmartFindAllVideoFiles, then you most likely
%didn't have this part done... I think... I hope... 

%FoundVideoFilesPath: DON'T INCLUDE THE FILENAME LIKE FOUNDVIDEOFILES.MAT
%DON'T INCLUDE THE BACKSLASH AT THE END
%JUST THE DIRECTORY
%is the path where you want FoundVideoFiles.mat to be 
%created OR where it already exists

%BBParentPath: SERIOUSLY DON'T FUCKING INCLUDE THE BACKSLASH 
%is the directory where all the BB folders are listed out.
%Keep in mind that you need ALL BB folders for this to work. This is also
%the place where ActigraphyResults folder will be created, so keep that in
%mind. So there WILL be a new folder in here

%GeneralOutputsPath: JUST INCLUDE THE FOLDER NAME WHERE YOU WANT EVERYTHING
%is where the tables, plots, and merged_actigraphy folders are going to be
%made. This can be pretty much anywhere.

%BatchProcessVideoFileAnalyzer(FoundVideoFilesPath,BBParentPath,BBlist,BBToAnalyze);
CombineActigraphyOutputResults(FoundVideoFilesPath,BBParentPath,GeneralOutputsPath,BBlist,BBToAnalyze);
ProduceActigraphyFinalOutputTable(FoundVideoFilesPath,BBParentPath,GeneralOutputsPath,BBlist,BBToAnalyze);
ExportCombinedActigraphyOutputs_ToPythonCSV(FoundVideoFilesPath,BBParentPath,GeneralOutputsPath,BBlist,BBToAnalyze);
ProduceActigraphyFinalOutputPlots(FoundVideoFilesPath,GeneralOutputsPath,BBlist,BBToAnalyze);


end