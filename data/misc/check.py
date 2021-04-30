
#quick check on the P5-P20 vmrk files: is there eachtly one of each marker

targets=('S  0','S  1','S  2','S  3','S  4','S  5','S  6','S  7','S  8','S  9','S 10','S 11','S 12','S 13','S 14','S 15','S 16','S 17','S 18','S 19','S 20','S 21','S 22','S 23','S 24','S 30','S 31','S 32','S 33','S 34','S 35','S 36','S 37','S 38','S 39','S 40','S 41','S 42','S 43','S 44','S 45','S 46','S 47','S 48','S 49','S 50','S 51','S 52','S 53','S 54','S 60','S 61','S 62','S 63','S 64','S 65','S 66','S 67','S 68','S 69','S 70','S 71','S 72','S 73','S 74','S 75','S 76','S 77','S 78','S 79','S 80','S 81','S 82','S 83','S 84','S 90','S 91','S 92','S 93','S 94','S 95','S 96','S 97','S 98','S 99','S100','S101','S102','S103','S104','S105','S106','S107','S108','S109','S110','S111','S112','S113','S114','S120','S121','S122','S123','S124','S125','S126','S127','S128','S129','S130','S131','S132','S133','S134','S135','S136','S137','S138','S139','S140','S141','S142','S143','S144','S150','S151','S152','S153','S154','S155','S156','S157','S158','S159','S160','S161','S162','S163','S164','S165','S166','S167','S168','S169','S170','S171','S172','S173','S174')

with open("file_list.txt",'r') as filename_file:
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

