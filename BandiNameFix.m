%Alright. Be CAREFUL with this function. It WILL change the names of the
%files inside the directory itself. It will not duplicate the files because
%that would simply take too much damn memory. So if you (or I) screw this
%up to name the files weirdly, say goodbye to the metadata, because the
%file names are all we got. User discretion is HIGHLY ADVISED (;-;)

function BandiNameFix(fileloc)
%Alright. Be CAREFUL with this function. It WILL change the names of the
%files inside the directory itself. It will not duplicate the files because
%that would simply take too much damn memory. So if you (or I) screw this
%up to name the files weirdly, say goodbye to the metadata, because the
%file names are all we got. User discretion is HIGHLY ADVISED (;-;)

%What it is:
%BehavioralBox_B01_T 2021-12-02 15-08-15-133
%What it needs to be:
%BehavioralBox_B17_T20210713-1800000000



vids = dir(fullfile(fileloc,'*.mp4'));

for i = 1:length(vids)
    whatitis = vids(i).name;
    whatitneedstobe = whatitis(whatitis~='-'); %We also need to add a '0' between SS and MS digits in the video name.
    comps = split(whatitneedstobe,' ');
    if length(comps)~=1
        whatitneedstobe = [comps{1} comps{2} '-' comps{3}];
        comps = split(whatitneedstobe,'.');
		
		%10.17.22, Josh; OBS has a standard '0' separator in the video timestamp after the HHMMSS values
		%Ex: for a video that was started at 1AM,02MIN,03SEC,456MS: the last part of the video name should be: '...-0102030456'
        %Add this '0' separator to the videotimestamp:
		insertedZeroSeparator = [comps{1}(1:34) '0' comps{1}(35:end)];
		comps{1} = insertedZeroSeparator;
		whatitneedstobe = [comps{1} comps{2}];
        
        movefile([fileloc '\' whatitis], [fileloc '\' whatitneedstobe]);
    end
end

end
