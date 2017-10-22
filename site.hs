--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend, (<>))
import           Hakyll
import           Data.List
import           Data.List.Split
import           System.FilePath
import           Hakyll.Core.Configuration
import           System.Process
import           Text.Pandoc.Options
import qualified Data.Map as M
import           Control.Monad (liftM, (<=<), foldM)


--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith config $ do
    let product = [(++ "images/*"), (++ "posts/*/images/*")] <*> ["", "zurich/"] in
        match (unionPatterns product) $ do
            route   idRoute
            let args = ["-", "-resize", "200000@", "-"] in
                compile $ getResourceLBS >>= withItemBody (unixFilterLBS "convert" args)
                -- resize to 200,000 px

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.markdown", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    let product = [(++ "posts/*")] <*> ["", "zurich/"] in
        match (unionPatterns product) $ do
            route $ setExtension "html"
            compile postCompiler

-- This was supposed to allow me intermediate folders for posts,
-- but for some reason isn't working. The pattern should match (tested in GHCI)
-- but no output files are produced.
--     let product = [(++ "posts/*/*")] <*> ["", "zurich/"] in
--         match (unionPatterns product) $ do
--             route idRoute
-- --             route $ (setExtension "html") `composeRoutes` (customRoute remIntermediateDir)
--             compile postCompiler

    let createArchive subdir =
            create [fromFilePath $ subdir ++ "archive.html"] $ do
                route idRoute
                compile $ do
                    posts <- recentFirst =<< loadAll (fromGlob $ subdir ++ "posts/*")
                    let archiveCtx =
                            listField "posts" postCtx (return posts) `mappend`
                            constField "title" "Archives"            `mappend`
                            defaultContext

                    makeItem ""
                        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                        >>= relativizeUrls

    foldl1 (>>) $ map createArchive ["", "zurich/"]


    let matchIndex subdir =
            match (fromGlob $ subdir ++ "index.html") $ do
                    route idRoute
                    compile $ do
                        posts <- take5OfRecentFirst =<< loadAll (fromGlob $ subdir ++ "posts/*")
                        let indexCtx =
                                listField "posts" postCtx (return posts) `mappend`
                                constField "title" "Home"                `mappend`
                                defaultContext

                        getResourceBody
                            >>= applyAsTemplate indexCtx
                            >>= loadAndApplyTemplate "templates/default.html" indexCtx
                            >>= relativizeUrls

    foldl1 (>>) $ map matchIndex ["", "zurich/"]


    match ("templates/*" .||. "zurich/templates/*") $ do
        route idRoute
        compile templateBodyCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext


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

unionPatterns patterns = foldl1 (.||.) (fmap fromGlob patterns)

postCompiler = pandocCompilerWith myReaderOptions myWriterOptions
                >>= loadAndApplyTemplate "templates/post.html" postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

-- remIntermediateDir id = intercalate "/" $ reverse $ removeSecond $ reverse $ splitOn "/" id'
--     where id'                       = toFilePath id
--           removeSecond (x:y:xs)     = x:xs