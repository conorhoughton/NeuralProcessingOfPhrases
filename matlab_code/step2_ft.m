

addpath /home/cscjh/fieldtrip/fieldtrip-20200607

ft_defaults

clearvars



    
      
% ----------- parameters, filenames
%low pass filter cutoff
lpf = 25; %Hz

sample_freq = 1000;

ms=0.001;

filepath = '/home/cscjh/Experiment2/processed_data/pre_processed/'
filepath_save = '/home/cscjh/Experiment2/processed_data/ft/'
%filepath_save = '/home/cscjh/Experiment2/processed_data/ft_no_blink_correction/'

filepath_filelist = '/home/cscjh/Experiment2/data/'
%filelist ='file_list.txt'
filelist ='file_list_P1-4.txt'

extra_load='_rm_front_4';         
extra_save='_ft';
extra_dat='_ft';
extra_trial='_trial';

%extra_load='';         
%extra_save='_ft_no_rm';
%extra_dat='_ft_no_rm';
%extra_trial='_trial';



% ----------- load filenames

filenames = strsplit(deblank(fileread(strcat(filepath_filelist,filelist))))

%  ---------- loop over files

for file_i=1:length(filenames)
    
    filename=filenames(file_i);
    filename=filename{1,1}
    
    freq_data = struct;

    ppt_data=struct;
    ppt_data_sc = struct;

    
    
    file_in = strcat(filepath,filename,extra_load);
    load(file_in, 'data');
                      
    cfg = [];
    cfg.output     = 'fourier';
    cfg.channel    = 'all';
    cfg.method     = 'mtmfft';
    cfg.taper      = 'hanning';
    cfg.foilim     = [0.25 4];
    cfg.keeptrials = 'yes';
    
    freq  = ft_freqanalysis(cfg, data);
        
    
    %save the whole data structure
    
    file_out = strcat(filepath_save,filename,extra_save);
    save(file_out, 'freq');
    
    %save the fourier coeff in a csv file - load.jl can load this and indicates the order it is
    %flattened in since it is a three-index array (trial / channel / freq)

    file_out = strcat(filepath_save,filename,extra_dat,'.dat');
    writematrix(freq.fourierspctrm ,file_out);
    
    %save the trialinfo - this gives the order the trials are in as is required for splitting by condition
    
    file_out = strcat(filepath_save,filename,extra_trial,'.dat');
    writematrix(freq.trialinfo ,file_out);
       
    
end


