defmodule ExBackend.Accounts.Message do
  @moduledoc """
  A module for sending messages, by email or phone, to the user.

  This module provides functions to be used with the Phauxth authentication
  library when confirming users or handling password resets. It uses
  Bamboo, with the LocalAdapter, which is a good development tool.
  For tests, it uses a test adapter, which is configured in the
  config/test.exs file.

  For production, you will need to setup a different email adapter.

  ## Bamboo with a different adapter

  Bamboo has adapters for Mailgun, Mailjet, Mandrill, Sendgrid, SMTP,
  SparkPost, PostageApp, Postmark and Sendcloud.

  There is also a LocalAdapter, which is great for local development.

  See [Bamboo](https://github.com/thoughtbot/bamboo) for more information.

  ## Other email / phone library

  If you do not want to use Bamboo, follow the instructions below:

  1. Edit this file, using the email / phone library of your choice
  2. Remove the lib/ex_backend/mailer.ex file
  3. Remove the Bamboo entries in the config/config.exs and config/test.exs files
  4. Remove bamboo from the deps section in the mix.exs file

  """

  import Bamboo.Email
  alias ExBackend.Mailer

  defp get_url_base do
    hostname = get_hostname()

    ssl = get_ssl()
    external_port = get_ext_port()

    protocol = get_protocol(ssl)

    port = get_port(ssl, external_port)

    protocol <> hostname <> port
  end

  def get_hostname do
    System.get_env("EXPOSED_DOMAIN_NAME") || Application.get_env(:ex_backend, :hostname)
  end

  def get_ssl do
    System.get_env("SSL") || Application.get_env(:ex_backend, :ssl)
  end

  def get_ext_port do
    System.get_env("EXTERNAL_PORT") || Application.get_env(:ex_backend, :external_port)
  end

  def get_protocol(ssl) do
    case ssl do
      true -> "https://"
      "true" -> "https://"
      _ -> "http://"
    end
  end

  def get_port(ssl, ext_port) do
    case {ssl, ext_port} do
      {_, nil} -> ""
      {_, 80} -> ""
      {_, "80"} -> ""
      {true, 443} -> ""
      {"true", 443} -> ""
      {true, "443"} -> ""
      {"true", "443"} -> ""
      ext_port -> ":" <> ext_port
    end
  end

  @doc """
  An email with a confirmation link in it.
  """
  def confirm_request(address, key) do
    app_label = System.get_env("APP_LABEL") || Application.get_env(:ex_backend, :app_label)
    hostname = get_url_base()

    prep_mail(address)
    |> subject("[#{app_label} Backend] Confirm your account")
    |> text_body("Confirm your email here #{hostname}/confirm?key=#{key}")
    |> build_html_body("""
    <h2 style="margin: 0; margin-bottom: 30px; font-family: 'Open Sans', 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif; font-weight: 300; line-height: 1.5; font-size: 24px; color: #294661 !important;">
      You&#39;re on your way!<br />
      Let&#39;s confirm your email address.
    </h2>

    <p style="margin: 0; margin-bottom: 30px; color: #294661; font-family: 'Open Sans', 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif; font-size: 16px; font-weight: 300;">
      By clicking on the following link, you are confirming your email address.
    </p>

    <table align="center" table cellpadding="0" cellspacing="0" style="box-sizing: border-box; border-spacing: 0; mso-table-rspace: 0pt; mso-table-lspace: 0pt; width: auto; border-collapse: separate !important;">
      <tbody>
        <tr>
          <td align="center" bgcolor="#348eda"
            style="box-sizing: border-box; padding: 0; font-family: 'Open Sans', 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif; font-size: 16px; vertical-align: top; background-color: #348eda; border-radius: 2px; text-align: center;"
            valign="top">
            <a href="#{hostname}/confirm?key=#{key}"
              style="box-sizing: border-box; border-color: #348eda; font-weight: 400; text-decoration: none; display: inline-block; margin: 0; color: #ffffff; background-color: #348eda; border: solid 1px #348eda; border-radius: 2px; cursor: pointer; font-size: 14px; padding: 12px 45px;">
              Confirm Email Address
            </a>
          </td>
        </tr>
      </tbody>
    </table>
    """)
    |> Mailer.deliver_now()
  end

  @doc """
  An email with a link to reset the password.
  """
  def reset_request(address, nil) do
    app_label = System.get_env("APP_LABEL") || Application.get_env(:ex_backend, :app_label)

    prep_mail(address)
    |> subject("[#{app_label} Backend] Reset your password")
    |> text_body(
      "You requested a password reset, but no user is associated with the email you provided."
    )
    |> Mailer.deliver_now()
  end

  def reset_request(address, key) do
    app_label = System.get_env("APP_LABEL") || Application.get_env(:ex_backend, :app_label)
    hostname = get_url_base()

    prep_mail(address)
    |> subject("[#{app_label} Backend] Reset your password")
    |> text_body("Reset your password at " <> hostname <> "/password_resets/edit?key=#{key}")
    |> Mailer.deliver_now()
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.
  """
  def confirm_success(address) do
    app_label = System.get_env("APP_LABEL") || Application.get_env(:ex_backend, :app_label)

    prep_mail(address)
    |> subject("[#{app_label} Backend] Confirmed account")
    |> text_body("Your account has been confirmed.")
    |> build_html_body("""
    <h2 style="margin: 0; margin-bottom: 30px; font-family: 'Open Sans', 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif; font-weight: 300; line-height: 1.5; font-size: 24px; color: #294661 !important;">
      Your account has been confirmed.
    </h2>
    """)
    |> Mailer.deliver_now()
  end

  @doc """
  An email acknowledging that the password has been successfully reset.
  """
  def reset_success(address) do
    app_label = System.get_env("APP_LABEL") || Application.get_env(:ex_backend, :app_label)

    prep_mail(address)
    |> subject("[#{app_label} Backend] Password reset")
    |> text_body("Your password has been reset.")
    |> Mailer.deliver_now()
  end

  defp prep_mail(address) do
    new_email()
    |> to(address)
    |> from(get_sender_email)
  end

  defp get_sender_email() do
    System.get_env("APP_SENDER_EMAIL") ||
      Application.get_env(:ex_backend, :sender_email, "no-reply@media-io.com")
  end

  defp build_html_body(config, content) do
    app_label = System.get_env("APP_LABEL") || Application.get_env(:ex_backend, :app_label)
    app_logo = System.get_env("APP_LOGO") || Application.get_env(:ex_backend, :app_logo)
    hostname = get_url_base()

    config
    |> html_body("""
    <head>
      <style type="text/css">
        @font-face {
          font-family: 'Open Sans';
          font-style: normal;
          font-weight: 300;
          src: local('Open Sans Light'), local('OpenSans-Light'), url(https://fonts.gstatic.com/s/opensans/v13/DXI1ORHCpsQm3Vp6mXoaTYnF5uFdDttMLvmWuJdhhgs.ttf) format('truetype');
        }

        @font-face {
          font-family: 'Open Sans';
          font-style: normal;
          font-weight: 400;
          src: local('Open Sans'), local('OpenSans'), url(https://fonts.gstatic.com/s/opensans/v13/cJZKeOuBrn4kERxqtaUH3aCWcynf_cDxXwCLxiixG1c.ttf) format('truetype');
        }

        @font-face {
          font-family: 'Open Sans';
          font-style: normal;
          font-weight: 600;
          src: local('Open Sans Semibold'), local('OpenSans-Semibold'), url(https://fonts.gstatic.com/s/opensans/v13/MTP_ySUJH_bn48VBG8sNSonF5uFdDttMLvmWuJdhhgs.ttf) format('truetype');
        }
      </style>

      <!--[if mso]>
        <style>
          h1, h2, h3, h4,
          p, ol, ul {
            font-family: Arial, sans-serif !important;
          }
        </style>
      <![endif]-->
    </head>

    <body style="font-size: 16px; background-color: #fdfdfd; margin: 0; padding: 0; font-family: 'Open Sans', 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif; -webkit-text-size-adjust: 100%; line-height: 1.5; -ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; height: 100% !important; width: 100% !important;">
      <table bgcolor="#fdfdfd" class="body" style="box-sizing: border-box; border-spacing: 0; mso-table-rspace: 0pt; mso-table-lspace: 0pt; width: 100%; background-color: #fdfdfd; border-collapse: separate !important;" width="100%">
        <tbody>
          <tr>
            <td>
              <div style="max-width: 440px; margin:auto; background-color: #3864aa;">
                &nbsp;<br/>
                <img alt="#{app_label}" height="22" src="#{hostname}/bundles/images/#{app_logo}" style="max-width: 100%; border-style: none; width: 123px; height: 22px;" width="123" />
                <br/>&nbsp;
              </div>
            </td>
          </tr>
          <tr>
            <td>
              <div bgcolor="#fffff" style="background-color: #ffffff; border: 1px solid #f0f0f0; padding: 20px; max-width: 400px; margin:auto;">
                #{content}
              <div>
            </td>
          </tr>
        </tbody>
      </table>
    </body>
    """)
  end
end
