function ActigraphyRun(FoundVideoFilesPath,BBParentPath,GeneralOutputsPath,BBlist,BBToAnalyze)

%% Hardcoded Values: 
AnalysisComputerisScatha = true;
ExperimentNumber = '05';
CohortNumber = '01';

BBlist = {'01', '02', '03', '04', '05','06', '07', '08',...
    '09', '10','11', '12', '13', '14', '15','16'};

BBToAnalyze = [true, false, false, false, false, false, false,...
    false, false, false, false, false, false, false, false];
              
if AnalysisComputerisScatha
    FoundVideoFilesPath = '/home/ghimirea/Documents/Experiment05Quadrantizing';
    BBParentPath = '/media/OverseerF/Videos';
    GeneralOutputsPath = '/home/ghimirea/Documents/Experiment05Quadrantizing/General_Outputs';
else 
    FoundVideoFilesPath = 'C:\Users\ghimirea\Desktop\Local Actisgraphy\Experiment_04Cohort01\Actigraphy Outputs';
    BBParentPath = 'C:\Users\ghimirea\Desktop\Local Actigraphy\Experiment_04Cohort01';
    GeneralOutputsPath = 'C:\Users\ghimirea\Desktop\Local Actigraphy\Experiment_04Cohort01\General Outputs';
end 

%Notes on naming: 
%Alright. Much like a lot of matlab functions that accept
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

%FoundVideoFilesPath: Is the path where you want FoundVideoFiles.mat to be 
%created OR where FoundVideoFiles.mat already exists.
%DON'T INCLUDE THE FILENAME LIKE FOUNDVIDEOFILES.MAT
%EX: '/home/ghimirea/Documents/Experiment05Quadrantizing' is correct,
%'/home/ghimirea/Documents/Experiment05Quadrantizing/FoundVideoFiles.mat' is incorrect.

%BBParentPath: Is the directory where all the BB folders which contain the videos are listed out.
%Ex:
%BBParentPath: '/media/OverseerF:/Videos' contains:
%                   BB01
%                   BB02
%                   BB03...
%
%Keep in mind that you need ALL BB folders for this to work. This is also
%the place where ActigraphyResults folder will be created.
%So there WILL be a new folder in here

%GeneralOutputsPath: JUST INCLUDE THE FOLDER NAME WHERE YOU WANT EVERYTHING
%is where the tables, plots, and merged_actigraphy folders are going to be
%made. This can be pretty much anywhere.

ExperimentToAnalyze = ['Experiment', ExperimentNumber];
CohortToAnalyze = ['Cohort', CohortNumber];

[current_included_bbIDs] = GenerateFoundVideoFiles(BBlist,BBToAnalyze,BBParentPath,FoundVideoFilesPath, ExperimentToAnalyze, CohortToAnalyze);
requadrantize( FoundVideoFilesPath,BBlist, BBToAnalyze, BBParentPath);
BatchProcessVideoFileAnalyzer(FoundVideoFilesPath,BBParentPath,BBlist,BBToAnalyze);
CombineActigraphyOutputResults(FoundVideoFilesPath,BBParentPath,GeneralOutputsPath,BBlist,BBToAnalyze);
ProduceActigraphyFinalOutputTable(FoundVideoFilesPath,BBParentPath,GeneralOutputsPath,BBlist,BBToAnalyze);
ExportCombinedActigraphyOutputs_ToPythonCSV(FoundVideoFilesPath,BBParentPath,GeneralOutputsPath,BBlist,BBToAnalyze);
ProduceActigraphyFinalOutputPlots(FoundVideoFilesPath,GeneralOutputsPath,BBlist,BBToAnalyze);


end