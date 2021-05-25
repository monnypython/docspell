package docspell.backend.ops

import cats.effect.{Effect, Resource}
import cats.implicits._

import docspell.common.syntax.all._
import docspell.common._
import docspell.store.Store

import org.log4s._
import docspell.common.AccountId
import io.circe.Json
import docspell.store.records.RClientSettings
import docspell.store.records.RUser
import cats.data.OptionT

trait OClientSettings[F[_]] {

  def delete(clientId: Ident, account: AccountId): F[Boolean]
  def save(clientId: Ident, account: AccountId, data: Json): F[Unit]
  def load(clientId: Ident, account: AccountId): F[Option[RClientSettings]]

}

object OClientSettings {
  private[this] val logger = getLogger

  def apply[F[_]: Effect](store: Store[F]): Resource[F, OClientSettings[F]] =
    Resource.pure[F, OClientSettings[F]](new OClientSettings[F] {

      private def getUserId(account: AccountId): OptionT[F, Ident] =
        OptionT(store.transact(RUser.findByAccount(account))).map(_.uid)

      def delete(clientId: Ident, account: AccountId): F[Boolean] =
        (for {
          _ <- OptionT.liftF(
            logger.fdebug(
              s"Deleting client settings for client ${clientId.id} and account $account"
            )
          )
          userId <- getUserId(account)
          n <- OptionT.liftF(
            store.transact(
              RClientSettings.delete(clientId, userId)
            )
          )
        } yield n > 0).getOrElse(false)

      def save(clientId: Ident, account: AccountId, data: Json): F[Unit] =
        (for {
          _ <- OptionT.liftF(
            logger.fdebug(
              s"Storing client settings for client ${clientId.id} and account $account"
            )
          )
          userId <- getUserId(account)
          n <- OptionT.liftF(
            store.transact(RClientSettings.upsert(clientId, userId, data))
          )
          _ <- OptionT.liftF(
            if (n <= 0) Effect[F].raiseError(new Exception("No rows updated!"))
            else ().pure[F]
          )
        } yield ()).getOrElse(())

      def load(clientId: Ident, account: AccountId): F[Option[RClientSettings]] =
        (for {
          _ <- OptionT.liftF(
            logger.fdebug(
              s"Loading client settings for client ${clientId.id} and account $account"
            )
          )
          userId <- getUserId(account)
          data   <- OptionT(store.transact(RClientSettings.find(clientId, userId)))
        } yield data).value

    })
}
