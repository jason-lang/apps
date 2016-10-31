package results.util;

import java.util.List;

public class AgentLine {
    int    step;
    String team;
    double bank;
    
    AgentLine(String line) {
        List<String> parse = CSVParser.parse(line);
        step = Integer.parseInt(parse.get(1));
        team = parse.get(2);
        bank = Double.parseDouble(parse.get(3)); 
    }
    
    @Override
    public String toString() {
        return step + ":" + team + " = "+bank;
    }
    
}
