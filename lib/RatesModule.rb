require 'net/http'
require 'uri'
require 'nokogiri'
require 'active_support/all'

module Rates

    def self.get(credentials, quote)

        url = URI.parse('https://wsbeta.fedex.com:443/xml')  # Reemplaza 'https://ejemplo.com/api' con la URL deseada

        # XML que se enviará en el cuerpo de la solicitud
        xml_body = <<~XML
            <RateRequest xmlns=\"http://fedex.com/ws/rate/v13\">
                <WebAuthenticationDetail>    
                    <UserCredential>
                        <Key>#{ credentials[:key] }</Key>
                        <Password>#{ credentials[:password] }</Password>
                    </UserCredential>
                </WebAuthenticationDetail>
                <ClientDetail>
                    <AccountNumber>510087720</AccountNumber>
                    <MeterNumber>119238439</MeterNumber>
                    <Localization>
                        <LanguageCode>es</LanguageCode>
                        <LocaleCode>mx</LocaleCode>
                    </Localization>
                </ClientDetail>
                <Version>
                    <ServiceId>crs</ServiceId>
                        <Major>13</Major>
                        <Intermediate>0</Intermediate>
                        <Minor>0</Minor>
                </Version>
                <ReturnTransitAndCommit>true</ReturnTransitAndCommit>  
                <RequestedShipment>
                    <DropoffType>REGULAR_PICKUP</DropoffType>
                    <PackagingType>YOUR_PACKAGING</PackagingType>
                    <Shipper>
                        <Address>
                            <StreetLines></StreetLines>
                            <City></City>        
                            <StateOrProvinceCode>XX</StateOrProvinceCode>
                            <PostalCode>#{ quote[:address_from][:zip] }</PostalCode>        
                            <CountryCode>#{ quote[:address_from][:country] }</CountryCode>      
                        </Address>
                    </Shipper>    
                    <Recipient>      
                        <Address>
                            <StreetLines></StreetLines>
                            <City></City>        
                            <StateOrProvinceCode>XX</StateOrProvinceCode>
                            <PostalCode>#{ quote[:address_to][:zip] }</PostalCode>
                            <CountryCode>#{ quote[:address_to][:country] }</CountryCode>
                            <Residential>false</Residential>
                        </Address>
                    </Recipient>
                    <ShippingChargesPayment>      
                        <PaymentType>SENDER</PaymentType>
                    </ShippingChargesPayment>
                    <RateRequestTypes>ACCOUNT</RateRequestTypes>
                    <PackageCount>1</PackageCount>    
                    <RequestedPackageLineItems>      
                        <GroupPackageCount>1</GroupPackageCount>      
                        <Weight>        
                            <Units>#{ quote[:parcel][:mass_unit] }</Units>        
                            <Value>1</Value>      
                        </Weight>      
                        <Dimensions>      
                            <Length>#{ quote[:parcel][:length] }</Length>      
                            <Width>#{ quote[:parcel][:width] }</Width>      
                            <Height>#{ quote[:parcel][:height] }</Height>      
                            <Units>#{ quote[:parcel][:distance_unit] }</Units>      
                        </Dimensions>    
                    </RequestedPackageLineItems>
                </RequestedShipment>
            </RateRequest>
        XML

        # Crear la solicitud HTTP
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == 'https')

        request = Net::HTTP::Post.new(url.path)
        request.body = xml_body
        request['Content-Type'] = 'application/xml' # Establecer el tipo de contenido como XML

        begin
        
            # Realizar la solicitud
            response = http.request(request)

            # Verificar la respuesta
            if response.code == '200'
                # Parsear la respuesta XML utilizando Nokogiri
                doc = Nokogiri::XML(response.body)
                # Convertimos la respuesta XML a un hash
                parsed_hash = Hash.from_xml(doc.to_xml)
                # Validamos hash
                if parsed_hash["RateReply"]["RateReplyDetails"][0]['RatedShipmentDetails'][1]['ShipmentRateDetail']['TotalNetChargeWithDutiesAndTaxes'] ? true : false
                    return parsed_hash["RateReply"]["RateReplyDetails"][0]['RatedShipmentDetails'][1]['ShipmentRateDetail']['TotalNetChargeWithDutiesAndTaxes']
                else
                    return { status: "error", msg: 'unknown error' }
                end
            else
                return { status: "error", msg: 'error in request' }
            end

        rescue Errno::ECONNREFUSED => e
            # Rescatar errores específicos relacionados con la red (conexión rechazada)
                return { status: "error", msg: "ECONNREFUSED: #{e.message}" }
        rescue Net::HTTPError, SocketError => e
            # Rescatar errores específicos de HTTP o de sockets
            return { status: "error", msg: "HTTPError: #{e.message}" }
        rescue => e
            # Capturar cualquier otro error inesperado
                return { status: "error", msg: "UNKNOWN: #{e.message}" }
        end
        
        
    end

end