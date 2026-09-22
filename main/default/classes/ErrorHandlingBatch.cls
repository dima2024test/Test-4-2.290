global class ErrorHandlingBatch implements Database.Batchable<Integer> {

    private final Integer occurrences;
    private final Integer logsPerOccurrence;

    global ErrorHandlingBatch() {
        this(50, 20);
    }

    global ErrorHandlingBatch(Integer occurrences, Integer logsPerOccurrence) {
        this.occurrences = occurrences;
        this.logsPerOccurrence = logsPerOccurrence;
    }

    // No SOQL: the number of chunks is a parameter instead of however many Accounts exist.
    global Iterable<Integer> start(Database.BatchableContext BC) {
        List<Integer> items = new List<Integer>();
        for (Integer i = 0; i < occurrences; i++) {
            items.add(i);
        }
        return items;
    }

    // One chunk per item (run with scope size 1), so the logs are spread over separate
    // transactions and no single debug log grows past the platform's 20 MB cap - which
    // would drop the EXCEPTION_THROWN line the trace pipeline needs.
    global void execute(Database.BatchableContext BC, List<Integer> scope) {
        try {
            Integer i = 2 / 0;
        } catch (Exception e) {
            for (Integer j = 0; j < logsPerOccurrence; j++) {
                Triton.log(Triton.t
                    .area(TritonTypes.Area.Accounts)
                    .exception(e)
                    .level(TritonTypes.Level.ERROR)
                    .traceable(true));
            }
            Triton.flush();
        }
    }

    global void finish(Database.BatchableContext BC) {}
}