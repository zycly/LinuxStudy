#!/bin/bash
function Bibble_sort
{
	local temp
	local k=0
	local array_function=(`echo $@`)
	for(( i = 0; i < $[$#-1]; i++ ))
	{
		k=$i
		for(( j=$[$i+1]; j < $#; j++ ))
		{
			if [ "${array_function[$j]}" -gt "${array_function[$k]}" ] 
			then
				k=$j
			fi
		}

		if [[ "$i" -ne  "$k" ]]
		then
			temp=${array_function[$i]}	
			array_function[$i]=${array_function[$k]}
			array_function[$k]=$temp;
		fi
	}
	echo ${array_function[@]}
}

array=(4 3 2 7 10 23)
result=(`Bibble_sort ${array[@]}`)  
echo ${result[@]}

exit 0
