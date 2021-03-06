/**
 * AddShoppingCartItemsRequest.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2.1 Jun 14, 2005 (09:15:57 EDT) WSDL2Java emitter.
 */

package com.amazon.soap;

public class AddShoppingCartItemsRequest  implements java.io.Serializable {
    private java.lang.String tag;
    private java.lang.String devtag;
    private java.lang.String cartId;
    private java.lang.String HMAC;
    private com.amazon.soap.AddItem[] items;
    private java.lang.String locale;

    public AddShoppingCartItemsRequest() {
    }

    public AddShoppingCartItemsRequest(
           java.lang.String tag,
           java.lang.String devtag,
           java.lang.String cartId,
           java.lang.String HMAC,
           com.amazon.soap.AddItem[] items,
           java.lang.String locale) {
           this.tag = tag;
           this.devtag = devtag;
           this.cartId = cartId;
           this.HMAC = HMAC;
           this.items = items;
           this.locale = locale;
    }


    /**
     * Gets the tag value for this AddShoppingCartItemsRequest.
     * 
     * @return tag
     */
    public java.lang.String getTag() {
        return tag;
    }


    /**
     * Sets the tag value for this AddShoppingCartItemsRequest.
     * 
     * @param tag
     */
    public void setTag(java.lang.String tag) {
        this.tag = tag;
    }


    /**
     * Gets the devtag value for this AddShoppingCartItemsRequest.
     * 
     * @return devtag
     */
    public java.lang.String getDevtag() {
        return devtag;
    }


    /**
     * Sets the devtag value for this AddShoppingCartItemsRequest.
     * 
     * @param devtag
     */
    public void setDevtag(java.lang.String devtag) {
        this.devtag = devtag;
    }


    /**
     * Gets the cartId value for this AddShoppingCartItemsRequest.
     * 
     * @return cartId
     */
    public java.lang.String getCartId() {
        return cartId;
    }


    /**
     * Sets the cartId value for this AddShoppingCartItemsRequest.
     * 
     * @param cartId
     */
    public void setCartId(java.lang.String cartId) {
        this.cartId = cartId;
    }


    /**
     * Gets the HMAC value for this AddShoppingCartItemsRequest.
     * 
     * @return HMAC
     */
    public java.lang.String getHMAC() {
        return HMAC;
    }


    /**
     * Sets the HMAC value for this AddShoppingCartItemsRequest.
     * 
     * @param HMAC
     */
    public void setHMAC(java.lang.String HMAC) {
        this.HMAC = HMAC;
    }


    /**
     * Gets the items value for this AddShoppingCartItemsRequest.
     * 
     * @return items
     */
    public com.amazon.soap.AddItem[] getItems() {
        return items;
    }


    /**
     * Sets the items value for this AddShoppingCartItemsRequest.
     * 
     * @param items
     */
    public void setItems(com.amazon.soap.AddItem[] items) {
        this.items = items;
    }


    /**
     * Gets the locale value for this AddShoppingCartItemsRequest.
     * 
     * @return locale
     */
    public java.lang.String getLocale() {
        return locale;
    }


    /**
     * Sets the locale value for this AddShoppingCartItemsRequest.
     * 
     * @param locale
     */
    public void setLocale(java.lang.String locale) {
        this.locale = locale;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof AddShoppingCartItemsRequest)) return false;
        AddShoppingCartItemsRequest other = (AddShoppingCartItemsRequest) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.tag==null && other.getTag()==null) || 
             (this.tag!=null &&
              this.tag.equals(other.getTag()))) &&
            ((this.devtag==null && other.getDevtag()==null) || 
             (this.devtag!=null &&
              this.devtag.equals(other.getDevtag()))) &&
            ((this.cartId==null && other.getCartId()==null) || 
             (this.cartId!=null &&
              this.cartId.equals(other.getCartId()))) &&
            ((this.HMAC==null && other.getHMAC()==null) || 
             (this.HMAC!=null &&
              this.HMAC.equals(other.getHMAC()))) &&
            ((this.items==null && other.getItems()==null) || 
             (this.items!=null &&
              java.util.Arrays.equals(this.items, other.getItems()))) &&
            ((this.locale==null && other.getLocale()==null) || 
             (this.locale!=null &&
              this.locale.equals(other.getLocale())));
        __equalsCalc = null;
        return _equals;
    }

    private boolean __hashCodeCalc = false;
    public synchronized int hashCode() {
        if (__hashCodeCalc) {
            return 0;
        }
        __hashCodeCalc = true;
        int _hashCode = 1;
        if (getTag() != null) {
            _hashCode += getTag().hashCode();
        }
        if (getDevtag() != null) {
            _hashCode += getDevtag().hashCode();
        }
        if (getCartId() != null) {
            _hashCode += getCartId().hashCode();
        }
        if (getHMAC() != null) {
            _hashCode += getHMAC().hashCode();
        }
        if (getItems() != null) {
            for (int i=0;
                 i<java.lang.reflect.Array.getLength(getItems());
                 i++) {
                java.lang.Object obj = java.lang.reflect.Array.get(getItems(), i);
                if (obj != null &&
                    !obj.getClass().isArray()) {
                    _hashCode += obj.hashCode();
                }
            }
        }
        if (getLocale() != null) {
            _hashCode += getLocale().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(AddShoppingCartItemsRequest.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://soap.amazon.com", "AddShoppingCartItemsRequest"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("tag");
        elemField.setXmlName(new javax.xml.namespace.QName("", "tag"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("devtag");
        elemField.setXmlName(new javax.xml.namespace.QName("", "devtag"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("cartId");
        elemField.setXmlName(new javax.xml.namespace.QName("", "CartId"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setMinOccurs(0);
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("HMAC");
        elemField.setXmlName(new javax.xml.namespace.QName("", "HMAC"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setMinOccurs(0);
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("items");
        elemField.setXmlName(new javax.xml.namespace.QName("", "Items"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://soap.amazon.com", "AddItem"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("locale");
        elemField.setXmlName(new javax.xml.namespace.QName("", "locale"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setMinOccurs(0);
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
    }

    /**
     * Return type metadata object
     */
    public static org.apache.axis.description.TypeDesc getTypeDesc() {
        return typeDesc;
    }

    /**
     * Get Custom Serializer
     */
    public static org.apache.axis.encoding.Serializer getSerializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanSerializer(
            _javaType, _xmlType, typeDesc);
    }

    /**
     * Get Custom Deserializer
     */
    public static org.apache.axis.encoding.Deserializer getDeserializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanDeserializer(
            _javaType, _xmlType, typeDesc);
    }

}
