global class ErrorHandlingBatch implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id FROM Account LIMIT 1]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            Integer i = 2 / 0;
        } catch (Exception e) {
            for (Integer j = 0; j < 1000; j++) {
                Triton.log(Triton.t
                    .area(TritonTypes.Area.Accounts)
                    .exception(e)
                    .level(TritonTypes.Level.ERROR));
            }
            Triton.flush();
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Test');
    }
}