package results.util;

import java.util.List;

public class CommLine {
    int    step;
    String sender, receiver;
    String type;
    
    CommLine(String line) {
        List<String> parse = CSVParser.parse(line);
        step = Integer.parseInt(parse.get(1));
        sender   = parse.get(2);
        receiver = parse.get(3);
        type     = parse.get(4);
    }
    
    @Override
    public String toString() {
        return step + ":" + sender + " > "+ type +" > "+receiver;
    }
    
}
