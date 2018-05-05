--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Text.Pandoc

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "static/*/*" $ do
        route idRoute
        compile copyFileCompiler

    match "images/*" $ do
        route idRoute
        compile copyFileCompiler

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    siteCtx

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "CNAME" $ do
      route   idRoute
      compile copyFileCompiler

    create ["rss.xml"]$ do
        route idRoute
        compile $ do
            posts <- loadAllSnapshots "posts/*" "content" >>= recentFirst
            renderRss feedConfiguration feedCtx posts

    match "templates/*" $ compile templateCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    siteCtx 

siteCtx :: Context String
siteCtx = 
    constField "baseurl" "" `mappend` 
    constField "site_description" "Interesting Apps built on the Ethereum Blockchain" `mappend`
    constField "twitter_username" "ethdotapp" `mappend`
    defaultContext

feedCtx :: Context String
feedCtx =
    bodyField "description"  `mappend`
    postCtx

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle = "Eth App",
      feedDescription = "Interesting Apps built on the Ethereum Blockchain",
      feedAuthorName = "Eth App",
      feedRoot = "https://eth.app",
      feedAuthorEmail = "ethapp@protonmail.com"
    }
