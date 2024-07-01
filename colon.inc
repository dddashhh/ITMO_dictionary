%define element 0x0
%macro colon 2
  %%key:
	  	db %1, 0
      %2:
      	dq element
      	dq %%key
      		
      	%define element %2

%endmacro