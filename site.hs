--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend, (<>))
import           Hakyll
import           Data.List
import           System.FilePath
import           Hakyll.Core.Configuration
import           System.Process
import           Text.Pandoc.Options
import qualified Data.Map as M
import           Control.Monad (liftM, (<=<))


--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith config $ do
    match ("images/*" .||. "zurich/images/*") $ do
        route   idRoute
        compile copyFileCompiler

--     match "zurich/images/*" $ do
--         route   idRoute
--         compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.markdown", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls


    match ("posts/*" .||. "zurich/posts/*") $ do
        route $ setExtension "html"
        compile $ pandocCompilerWith myReaderOptions myWriterOptions
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

--     -- zurich
--     match "zurich/posts/*" $ do
--         route $ setExtension "html"
--         compile $ pandocCompilerWith myReaderOptions myWriterOptions
--             >>= loadAndApplyTemplate "templates/post.html"    postCtx
--             >>= loadAndApplyTemplate "templates/default.html" postCtx
--             >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    -- zurich
    create ["zurich/archive.html"] $ do
        route idRoute
        compile $ do
            zurichPosts <- recentFirst =<< loadAll "zurich/posts/*"
            let archiveCtx =
                    listField "zurichposts" postCtx (return zurichPosts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "zurich/templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- take5OfRecentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    -- zurich
    match "zurich/index.html" $ do
        route idRoute
        compile $ do
            zurichPosts <- take5OfRecentFirst =<< loadAll "zurich/posts/*"
            let indexCtx =
                    listField "zurichposts" postCtx (return zurichPosts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls


    match ("templates/*" .||. "zurich/templates/*") $ do
        route idRoute
        compile templateBodyCompiler

--     -- zurich
--     match "zurich/templates/*" $ do
--         route idRoute
--         compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

-- added this for GitHub Pages

-- shortened Config
-- config :: Configuration
-- config = Configuration
--     { destinationDirectory = "docs"
--     , storeDirectory       = "_cache"
--     , tmpDirectory         = "_cache/tmp"
--     , providerDirectory    = "."
--     , ignoreFile           = ignoreFile'
--     , deployCommand        = "echo 'No deploy command specified' && exit 1"
--     , deploySite           = system . deployCommand
--     , inMemoryCache        = True
--     , previewHost          = "127.0.0.1"
--     , previewPort          = 8000
--     }
--   where
--     ignoreFile' path
--         | "."    `isPrefixOf` fileName = True
--         | "#"    `isPrefixOf` fileName = True
--         | "~"    `isSuffixOf` fileName = True
--         | ".swp" `isSuffixOf` fileName = True
--         | otherwise                    = False
--       where
--         fileName = takeFileName path

config :: Configuration
config = defaultConfiguration
    {
        destinationDirectory = "docs"
    }

myReaderOptions :: ReaderOptions
myReaderOptions = defaultHakyllReaderOptions

myWriterOptions :: WriterOptions
myWriterOptions = defaultHakyllWriterOptions {
      writerReferenceLinks = True
    , writerHtml5 = True
    , writerHighlight = True
    , writerHTMLMathMethod = MathJax "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js"
    }

-- mathCtx :: Context String
-- mathCtx = field "mathjax" $ \item -> do
--     metadata <- getMetadata $ itemIdentifier item
--     return lookupString "mathjax"
-- --     return $ if "mathjax" `M.member` metadata
-- --              then "<script type=\"text/javascript\" src=\"http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML\"></script>"
-- --              else ""

take5OfRecentFirst = (liftM (take 5)) .  recentFirst