#/bin/bash

#java -cp $( echo lib/*.jar bin/classes | sed 's/ /:/g') jade.Boot -container -host localhost -agents "gaucho1:jason.infra.jade.JadeAgArch(j-project AC-jason-local.mas2j gaucho1)"
java -cp $( echo lib/*.jar bin/classes | sed 's/ /:/g') jade.Boot -container -host localhost -agents \
	"gaucho6:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j gaucho6) 
	gaucho7:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j gaucho7) 
	gaucho8:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j gaucho8) 
	gaucho9:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j gaucho9) 
	gaucho10:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j gaucho10)" 
#java -cp $( echo lib/*.jar bin/classes | sed 's/ /:/g') jade.Boot -container -host localhost -agents "orgManager:jason.infra.jade.JadeAgArch(j-project AC-jason-local.mas2j orgManager)"
		

