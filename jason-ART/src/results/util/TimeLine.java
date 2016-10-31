package results.util;

import java.util.List;

public class TimeLine {
    int    step;
    String team;
    String method;
    long   time;
    
    TimeLine(String line) {
        List<String> parse = CSVParser.parse(line);
        step = Integer.parseInt(parse.get(1));
        team = parse.get(2);
        method = parse.get(4);
        time = Long.parseLong(parse.get(4)); 
    }
    
    @Override
    public String toString() {
        return step + ":" + team + " = "+time;
    }
    
}
