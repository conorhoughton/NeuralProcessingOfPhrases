# 1. Data Summary

The file ```full_data.csv``` is required by model fitting scripts. It can be
generated using the make_stan_data.jl script in the julia folder. It is a dataframe, stored as csv, with the following columns:

* **participant** : participant ID
* **name** : file name for the participant file 
* **condition** : the stimulus condition as a string
* **conditionC** : integer coding of stimulus condition 
* **trial** : trial number
* **electrode** : electride number
* **freqC** : index coding for frequency
* **freq** : frequency value
* **ft** : Fourier coefficient
* **phase** : ft/|ft|
* **angle** : angle(ft)

## 1.1 Stimulus Coding

The integer coding of the stimulus condition is as follows:

| Integer code | Stimulus name (data) | Stimulus name (paper)  |
| :---         |:---           |:---             |
| 1            | advp          | ML              |
| 2            | rrrr          | RR              |
| 3            | rrrv          | RV              |
| 4            | avav          | AV              |
| 5            | anan          | AN              |
| 6            | phmi          | MP              |

## 1.2 Electrode Coding

The electode number can be translated to location using the information in ```EEG1005.lay```. Electrode names can be looked up in ```channel_list.txt```.
