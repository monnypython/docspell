package docspell.common

sealed trait NlpMode { self: Product =>

  def name: String =
    self.productPrefix
}
object NlpMode {
  case object Full     extends NlpMode
  case object Basic    extends NlpMode
  case object Disabled extends NlpMode

  def fromString(name: String): Either[String, NlpMode] =
    name.toLowerCase match {
      case "full"     => Right(Full)
      case "basic"    => Right(Basic)
      case "disabled" => Right(Disabled)
      case _          => Left(s"Unknown nlp-mode: $name")
    }

  def unsafeFromString(name: String): NlpMode =
    fromString(name).fold(sys.error, identity)
}
