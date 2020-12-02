{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ViewPatterns      #-}
module Render.HTML(htmlFromColSpans) where

import Prelude hiding(span, id)
import Data.Text(Text)
import qualified Data.Text as T
import qualified Data.Text.Lazy as LT
import Text.Blaze.Html5 hiding(style)
import Text.Blaze.Html5.Attributes(colspan, style, id)
import Text.Blaze.Html.Renderer.Text(renderHtml)

import Alignment ( Align(..) )
import Render.Common(TokensWithColSpan)
import Token        (MyTok(..))
import Util ( preformatTokens, unbrace )

htmlFromColSpans ::   p
                 -> [[TokensWithColSpan]]
                 ->   Text
htmlFromColSpans cols =
    LT.toStrict
  . renderHtml
  . table
  . tbody
  . mapM_ renderTr

renderTr :: [TokensWithColSpan] -> Html
renderTr colspans = tr (mapM_ renderColSpan colspans)

renderColSpan :: TokensWithColSpan -> Html
renderColSpan ([(TBlank, txt)], colSpan, AIndent) = -- indentation
    td (toHtml txt)
       ! colspan (toValue colSpan)
       ! style   widthStyle
  where
    widthStyle = toValue $ "min-width: " <> show (T.length txt) <> "ex"
renderColSpan (toks, colSpan, alignment) =
    td (formatTokens toks)
       ! colspan (toValue colSpan)
       ! style   alignStyle
  where
    alignStyle        = "text-align: " <> alignMark alignment
    alignMark ACenter = "center"
    alignMark ALeft   = "left"

-- TODO: braced operators
formatTokens :: [(MyTok, Text)] -> Html
formatTokens  = mapM_ formatToken
              . preformatTokens

-- | Format a single token as HTML fragment.
formatToken :: (MyTok, Text) -> Html
formatToken (TOperator,unbrace -> Just op) = do "("
                                                formatToken (TOperator, op)
                                                ")"
formatToken (TOperator,"|>"       ) = "⊳"
formatToken (TOperator,"<>"       ) = "⋄"
formatToken (TOperator,"=>"       ) = "⇒"
formatToken (TOperator,"->"       ) = "→"
formatToken (TOperator,"|->"      ) = "↦"
formatToken (TVar     ,"undefined") = "⊥"
formatToken (TVar     ,"bot"      ) = "⊥"
formatToken (TVar     ,"not"      ) = "¬"
formatToken (TVar     ,"a"        ) = "α"
formatToken (TVar     ,"b"        ) = "β"
formatToken (TVar     ,"c"        ) = "γ"
formatToken (TVar     ,"d"        ) = "δ"
formatToken (TVar     ,"pi"       ) = "π"
formatToken (TVar     ,"eps"      ) = "ε"
formatToken (TKeyword ,"\\"       ) = "λ"
formatToken (TKeyword, "forall"   ) = "∀"
formatToken (TOperator,"elem"     ) = "∈"
formatToken (TOperator,"<="       ) = "≤"
formatToken (TOperator,">="       ) = "≥"
formatToken (TOperator,"mempty"   ) = "∅"
formatToken (TOperator,">>>"      ) = "⋙"
formatToken (TOperator,"<<<"      ) = "⋘"
formatToken (TOperator,"||"       ) = "∥"
formatToken (TOperator,"<->"      ) = "↔︎"
formatToken (TOperator,"<-"       ) = "←"
formatToken (TOperator,"-<"       ) = "≺"
formatToken (TOperator,">-"       ) = "≻"
formatToken (TOperator,"!="       ) = "≠"
formatToken (TOperator,"\\/"      ) = "⋁"
formatToken (TOperator,"/\\"      ) = "⋀"
formatToken (TOperator,"~"        ) = "∼"
formatToken (TOperator,"~="       ) = "≈"
formatToken (TVar,     "top"      ) = "⊤"
formatToken (TKeyword,  kwd       ) = b $ toHtml kwd
formatToken (TVar,      v         ) = i $ toHtml v
formatToken (TCons,     v         ) = span (toHtml v)
                                      ! style ("font-variant: small-caps;")
formatToken (TTikz mark,_         ) = span ""
                                      ! id (toValue mark)
formatToken (_,         txt       ) = toHtml txt

