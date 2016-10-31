/**
 * SellerFeedback.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2.1 Jun 14, 2005 (09:15:57 EDT) WSDL2Java emitter.
 */

package com.amazon.soap;

public class SellerFeedback  implements java.io.Serializable {
    private com.amazon.soap.Feedback[] feedback;

    public SellerFeedback() {
    }

    public SellerFeedback(
           com.amazon.soap.Feedback[] feedback) {
           this.feedback = feedback;
    }


    /**
     * Gets the feedback value for this SellerFeedback.
     * 
     * @return feedback
     */
    public com.amazon.soap.Feedback[] getFeedback() {
        return feedback;
    }


    /**
     * Sets the feedback value for this SellerFeedback.
     * 
     * @param feedback
     */
    public void setFeedback(com.amazon.soap.Feedback[] feedback) {
        this.feedback = feedback;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof SellerFeedback)) return false;
        SellerFeedback other = (SellerFeedback) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.feedback==null && other.getFeedback()==null) || 
             (this.feedback!=null &&
              java.util.Arrays.equals(this.feedback, other.getFeedback())));
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
        if (getFeedback() != null) {
            for (int i=0;
                 i<java.lang.reflect.Array.getLength(getFeedback());
                 i++) {
                java.lang.Object obj = java.lang.reflect.Array.get(getFeedback(), i);
                if (obj != null &&
                    !obj.getClass().isArray()) {
                    _hashCode += obj.hashCode();
                }
            }
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(SellerFeedback.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://soap.amazon.com", "SellerFeedback"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("feedback");
        elemField.setXmlName(new javax.xml.namespace.QName("", "Feedback"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://soap.amazon.com", "Feedback"));
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
