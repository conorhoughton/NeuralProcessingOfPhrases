
#quick check on the P5-P20 vmrk files: is there eachtly one of each marker

targets=('S 90','S 91','S 92','S 93','S 94','S 95','S 96','S 97','S 99','S100','S101','S102','S103','S104','S105','S106','S107','S108','S109','S110','S111','S112','S113','S114','S120','S121','S122','S123','S124','S125','S126','S127','S128','S129','S130','S131','S132','S133','S134','S135','S136','S137','S138','S139','S140','S141','S142','S143','S144','S150','S151','S152','S153','S154','S155','S156','S157','S158','S159','S160','S161','S162','S163','S164','S165','S166','S167','S168','S169','S170','S171','S172','S173','S174')

with open("file_list_P1-4.txt",'r') as filename_file:
    lines=filename_file.readlines()
    for name in lines:
        filename=name.strip()
        print(filename,end=" ")
        f=open(filename+".vmrk",'r')
        text=f.read()
        for t in targets:
            n=text.count(t)
            if n!=1:
                print(t,end=" ")
        print()

