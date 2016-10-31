#/bin/bash

#java -cp $( echo lib/*.jar bin/classes | sed 's/ /:/g') jade.Boot -container -host localhost -agents "gaucho1:jason.infra.jade.JadeAgArch(j-project AC-jason-local.mas2j gaucho1)"
java -cp $( echo lib/*.jar bin/classes | sed 's/ /:/g') jade.Boot -container -host localhost -agents \
	"orgManager:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j orgManager) 
	gaucho1:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j gaucho1) 
	gaucho2:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j gaucho2) 
	gaucho3:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j gaucho3) 
	gaucho4:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j gaucho4) 
	gaucho5:jason.infra.jade.JadeAgArch(j-project AC-jason-jade.mas2j gaucho5)" 
#java -cp $( echo lib/*.jar bin/classes | sed 's/ /:/g') jade.Boot -container -host localhost -agents "orgManager:jason.infra.jade.JadeAgArch(j-project AC-jason-local.mas2j orgManager)"
		

