public class ErrorShapeProbe implements Database.Batchable<Integer> {

    public class ProbeException extends Exception {}

    public Iterable<Integer> start(Database.BatchableContext BC) {
        return new List<Integer>{1, 2, 3, 4, 5, 6};
    }

    public void execute(Database.BatchableContext BC, List<Integer> scope) {
        Integer shape = scope[0];
        try {
            if (shape == 1) {
                Account a = null;
                String s = a.Name;                       // NPE, оператор
            } else if (shape == 2) {
                List<String> l = new List<String>();
                String s = l[5];                         // выход за границы, оператор
            } else if (shape == 3) {
                Integer i = 2 / 0;                       // деление, оператор
            } else if (shape == 4) {
                insert new Account();                    // DML-оператор без обязательного поля
            } else if (shape == 5) {
                throw new ProbeException('custom throw'); // оператор throw
            } else if (shape == 6) {
                deepCall();                              // вызов метода
            }
        } catch (Exception e) {
            Triton.log(Triton.t
                .area(TritonTypes.Area.Accounts)
                .exception(e)
                .level(TritonTypes.Level.ERROR));
            Triton.flush();
        }
    }

    private void deepCall() {
        Integer i = 2 / 0;
    }

    public void finish(Database.BatchableContext BC) {}
}