/**
 * KeyPhrase.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2.1 Jun 14, 2005 (09:15:57 EDT) WSDL2Java emitter.
 */

package com.amazon.soap;

public class KeyPhrase  implements java.io.Serializable {
    private java.lang.String keyPhrase;
    private java.lang.String type;

    public KeyPhrase() {
    }

    public KeyPhrase(
           java.lang.String keyPhrase,
           java.lang.String type) {
           this.keyPhrase = keyPhrase;
           this.type = type;
    }


    /**
     * Gets the keyPhrase value for this KeyPhrase.
     * 
     * @return keyPhrase
     */
    public java.lang.String getKeyPhrase() {
        return keyPhrase;
    }


    /**
     * Sets the keyPhrase value for this KeyPhrase.
     * 
     * @param keyPhrase
     */
    public void setKeyPhrase(java.lang.String keyPhrase) {
        this.keyPhrase = keyPhrase;
    }


    /**
     * Gets the type value for this KeyPhrase.
     * 
     * @return type
     */
    public java.lang.String getType() {
        return type;
    }


    /**
     * Sets the type value for this KeyPhrase.
     * 
     * @param type
     */
    public void setType(java.lang.String type) {
        this.type = type;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof KeyPhrase)) return false;
        KeyPhrase other = (KeyPhrase) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.keyPhrase==null && other.getKeyPhrase()==null) || 
             (this.keyPhrase!=null &&
              this.keyPhrase.equals(other.getKeyPhrase()))) &&
            ((this.type==null && other.getType()==null) || 
             (this.type!=null &&
              this.type.equals(other.getType())));
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
        if (getKeyPhrase() != null) {
            _hashCode += getKeyPhrase().hashCode();
        }
        if (getType() != null) {
            _hashCode += getType().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(KeyPhrase.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://soap.amazon.com", "KeyPhrase"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("keyPhrase");
        elemField.setXmlName(new javax.xml.namespace.QName("", "KeyPhrase"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setMinOccurs(0);
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("type");
        elemField.setXmlName(new javax.xml.namespace.QName("", "Type"));
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
