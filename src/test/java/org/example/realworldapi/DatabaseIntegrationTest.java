package org.example.realworldapi;

import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.transaction.Transactional;

public class DatabaseIntegrationTest {

    @Inject
    protected EntityManager entityManager;

    public void clear() {
        transaction(
                () ->
                        entityManager.createNativeQuery(
                                "DELETE FROM articles_users; "
                                        + "DELETE FROM articles_tags; "
                                        + "DELETE FROM comments; "
                                        + "DELETE FROM articles; "
                                        + "DELETE FROM tags; "
                                        + "DELETE FROM followed_users; "
                                        + "DELETE FROM users; "
                        ).executeUpdate()
        );
    }

    @Transactional
    public void transaction(Runnable command) {
        // entityManager.getTransaction().begin();
        entityManager.flush();
        command.run();
        // entityManager.getTransaction().commit();
    }

    @Transactional
    public <T> T transaction(TransactionRunnable<T> command) {
        // entityManager.getTransaction().begin();
        entityManager.clear();
        T result = command.run();
        // entityManager.getTransaction().commit();
        return result;
    }

    public interface TransactionRunnable<T> {
        T run();
    }
}
