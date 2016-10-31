package testbed.participants;

import java.util.List;

import testbed.messages.ReputationAcceptOrDeclineMsg;

/**
 * Same as simple, but does not produce opinions!
 */
@SuppressWarnings("unchecked")
public class LazyAgent extends MyHonestAgent {

	@Override
	public void prepareReputationReplies() {
	    @SuppressWarnings("unused")
        List<ReputationAcceptOrDeclineMsg> reputationAcceptsAndDeclines = getIncomingMessages();
	}
	
	@Override
    public void prepareOpinionCreationOrders() {
        opinionRequests = getIncomingMessages();
    }
}
