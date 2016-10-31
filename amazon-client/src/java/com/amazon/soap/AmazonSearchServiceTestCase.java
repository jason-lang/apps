/**
 * AmazonSearchServiceTestCase.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2.1 Jun 14, 2005 (09:15:57 EDT) WSDL2Java emitter.
 */

package com.amazon.soap;

public class AmazonSearchServiceTestCase extends junit.framework.TestCase {
    public AmazonSearchServiceTestCase(java.lang.String name) {
        super(name);
    }

    public void testAmazonSearchPortWSDL() throws Exception {
        javax.xml.rpc.ServiceFactory serviceFactory = javax.xml.rpc.ServiceFactory.newInstance();
        java.net.URL url = new java.net.URL(new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPortAddress() + "?WSDL");
        javax.xml.rpc.Service service = serviceFactory.createService(url, new com.amazon.soap.AmazonSearchServiceLocator().getServiceName());
        assertTrue(service != null);
    }

    public void test1AmazonSearchPortKeywordSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.keywordSearchRequest(new com.amazon.soap.KeywordRequest());
        // TBD - validate results
    }

    public void test2AmazonSearchPortPowerSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.powerSearchRequest(new com.amazon.soap.PowerRequest());
        // TBD - validate results
    }

    public void test3AmazonSearchPortBrowseNodeSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.browseNodeSearchRequest(new com.amazon.soap.BrowseNodeRequest());
        // TBD - validate results
    }

    public void test4AmazonSearchPortAsinSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.asinSearchRequest(new com.amazon.soap.AsinRequest());
        // TBD - validate results
    }

    public void test5AmazonSearchPortBlendedSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductLine[] value = null;
        value = binding.blendedSearchRequest(new com.amazon.soap.BlendedRequest());
        // TBD - validate results
    }

    public void test6AmazonSearchPortUpcSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.upcSearchRequest(new com.amazon.soap.UpcRequest());
        // TBD - validate results
    }

    public void test7AmazonSearchPortAuthorSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.authorSearchRequest(new com.amazon.soap.AuthorRequest());
        // TBD - validate results
    }

    public void test8AmazonSearchPortArtistSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.artistSearchRequest(new com.amazon.soap.ArtistRequest());
        // TBD - validate results
    }

    public void test9AmazonSearchPortActorSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.actorSearchRequest(new com.amazon.soap.ActorRequest());
        // TBD - validate results
    }

    public void test10AmazonSearchPortManufacturerSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.manufacturerSearchRequest(new com.amazon.soap.ManufacturerRequest());
        // TBD - validate results
    }

    public void test11AmazonSearchPortDirectorSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.directorSearchRequest(new com.amazon.soap.DirectorRequest());
        // TBD - validate results
    }

    public void test12AmazonSearchPortListManiaSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.listManiaSearchRequest(new com.amazon.soap.ListManiaRequest());
        // TBD - validate results
    }

    public void test13AmazonSearchPortWishlistSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.wishlistSearchRequest(new com.amazon.soap.WishlistRequest());
        // TBD - validate results
    }

    public void test14AmazonSearchPortExchangeSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ListingProductDetails value = null;
        value = binding.exchangeSearchRequest(new com.amazon.soap.ExchangeRequest());
        // TBD - validate results
    }

    public void test15AmazonSearchPortMarketplaceSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.MarketplaceSearch value = null;
        value = binding.marketplaceSearchRequest(new com.amazon.soap.MarketplaceRequest());
        // TBD - validate results
    }

    public void test16AmazonSearchPortSellerProfileSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.SellerProfile value = null;
        value = binding.sellerProfileSearchRequest(new com.amazon.soap.SellerProfileRequest());
        // TBD - validate results
    }

    public void test17AmazonSearchPortSellerSearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.SellerSearch value = null;
        value = binding.sellerSearchRequest(new com.amazon.soap.SellerRequest());
        // TBD - validate results
    }

    public void test18AmazonSearchPortSimilaritySearchRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ProductInfo value = null;
        value = binding.similaritySearchRequest(new com.amazon.soap.SimilarityRequest());
        // TBD - validate results
    }

    public void test19AmazonSearchPortGetShoppingCartRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ShoppingCart value = null;
        value = binding.getShoppingCartRequest(new com.amazon.soap.GetShoppingCartRequest());
        // TBD - validate results
    }

    public void test20AmazonSearchPortClearShoppingCartRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ShoppingCart value = null;
        value = binding.clearShoppingCartRequest(new com.amazon.soap.ClearShoppingCartRequest());
        // TBD - validate results
    }

    public void test21AmazonSearchPortAddShoppingCartItemsRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ShoppingCart value = null;
        value = binding.addShoppingCartItemsRequest(new com.amazon.soap.AddShoppingCartItemsRequest());
        // TBD - validate results
    }

    public void test22AmazonSearchPortRemoveShoppingCartItemsRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ShoppingCart value = null;
        value = binding.removeShoppingCartItemsRequest(new com.amazon.soap.RemoveShoppingCartItemsRequest());
        // TBD - validate results
    }

    public void test23AmazonSearchPortModifyShoppingCartItemsRequest() throws Exception {
        com.amazon.soap.AmazonSearchBindingStub binding;
        try {
            binding = (com.amazon.soap.AmazonSearchBindingStub)
                          new com.amazon.soap.AmazonSearchServiceLocator().getAmazonSearchPort();
        }
        catch (javax.xml.rpc.ServiceException jre) {
            if(jre.getLinkedCause()!=null)
                jre.getLinkedCause().printStackTrace();
            throw new junit.framework.AssertionFailedError("JAX-RPC ServiceException caught: " + jre);
        }
        assertNotNull("binding is null", binding);

        // Time out after a minute
        binding.setTimeout(60000);

        // Test operation
        com.amazon.soap.ShoppingCart value = null;
        value = binding.modifyShoppingCartItemsRequest(new com.amazon.soap.ModifyShoppingCartItemsRequest());
        // TBD - validate results
    }

}
